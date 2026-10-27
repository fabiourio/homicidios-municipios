"""
Prepara as tabelas do projeto a partir das extrações brutas.

Entradas (pasta dados/raw/):
  sidra_raw.json   - extração da API SIDRA (Censo 2022), valores como vieram da API
  tabnet_raw.json  - extração do TabNet/SIM (óbitos por causas externas, residência)

Saídas (pasta dados/tabelas/):
  sidra_<tabela>.csv            - cada tabela SIDRA em formato largo, valores brutos
  censo2022_municipios.csv      - covariáveis municipais derivadas (limpas)
  sim_causas_externas_2021_2023.csv, sim_causas_externas_2024.csv
  municipios_amazonia_legal.csv, municipios_faixa_fronteira.csv
  base_analitica.csv            - base final, 1 linha por município
  dicionario.csv                - descrição de cada coluna da base final

Símbolos do IBGE: "-" = zero absoluto; "X" = suprimido (sigilo); ".." / "..." = não se aplica / não disponível.
"""
import json, html, io, re, os
from pathlib import Path
import numpy as np, pandas as pd

os.chdir(Path(__file__).resolve().parents[1] / "dados")   # caminhos abaixo são relativos a dados/

os.makedirs("tabelas", exist_ok=True)
S = json.load(open("raw/sidra_raw.json"))
UF = {11: "RO", 12: "AC", 13: "AM", 14: "RR", 15: "PA", 16: "AP", 17: "TO", 21: "MA", 22: "PI", 23: "CE", 24: "RN", 25: "PB",
      26: "PE", 27: "AL", 28: "SE", 29: "BA", 31: "MG", 32: "ES", 33: "RJ", 35: "SP", 41: "PR", 42: "SC", 43: "RS", 50: "MS",
      51: "MT", 52: "GO", 53: "DF"}
REG = {1: "N", 2: "NE", 3: "SE", 4: "S", 5: "CO"}

# ---------------------------------------------------------------------------
# 1. Tabelas SIDRA brutas -> CSV com nomes curtos
# ---------------------------------------------------------------------------
curto = {
    "4709": ["pop"],
    "4714": ["pop", "area_km2", "densidade"],
    "10295": ["moradores_dpp", "rend_pc_media", "rend_pc_mediana"],
    "10300": ["p14_total", "p14_ate_1_4sm", "p14_1_4_a_1_2sm", "p14_1_2_a_1sm", "p14_1_a_2sm", "p14_2_a_3sm", "p14_3_a_5sm",
              "p14_5_a_10sm", "p14_10_a_15sm", "p14_15_a_20sm", "p14_mais_20sm", "p14_sem_rendimento"],
    "9517": ["p14_total", "forca_trabalho", "ocupados", "desocupados", "fora_forca_trabalho"],
    "9543": ["taxa_alfabetizacao_15mais"],
    "9923": ["pop_total", "pop_urbana", "pop_rural"],
    "9605": ["pop_total", "branca", "preta", "amarela", "parda", "indigena"],
    "9606": ["homens_15_19", "homens_20_24", "homens_25_29"],
}
simbolos = {}
num = {}
for t, d in S.items():
    df = pd.DataFrame(d["rows"], columns=["cod_ibge", "municipio"] + curto[t]).astype({"cod_ibge": int}).sort_values("cod_ibge")
    df.to_csv(f"tabelas/sidra_{t}.csv", index=False)                       # bruto, como veio da API
    v = df[curto[t]]
    simbolos[t] = {s: int((v == s).sum().sum()) for s in ["-", "X", "..", "..."]}
    n = v.replace({"-": 0}).apply(pd.to_numeric, errors="coerce")           # "-" = 0; X/../... = NA
    n.insert(0, "cod_ibge", df.cod_ibge.values)
    num[t] = n.set_index("cod_ibge")
print("Símbolos encontrados por tabela:", json.dumps(simbolos))

# Dicionário das tabelas SIDRA (rótulo completo de cada coluna)
rows = []
for t, d in S.items():
    for c, lab in zip(curto[t], d["cols"]):
        rows.append(dict(tabela=t, coluna=c, descricao_sidra=lab, consulta_api=d["url"]))
pd.DataFrame(rows).to_csv("tabelas/sidra_dicionario.csv", index=False)

# ---------------------------------------------------------------------------
# 2. Covariáveis derivadas
# ---------------------------------------------------------------------------
nomes = pd.DataFrame(S["4709"]["rows"], columns=["cod_ibge", "municipio", "x"]).astype({"cod_ibge": int}).set_index("cod_ibge")
c = pd.DataFrame(index=num["4709"].index)
c["municipio"] = nomes.municipio.str.replace(r" - [A-Z]{2}$", "", regex=True)
c["uf"] = [UF[i // 100000] for i in c.index]
c["regiao"] = [REG[i // 1000000] for i in c.index]
c["pop"] = num["4709"]["pop"]
c["area_km2"] = num["4714"]["area_km2"]
c["dens"] = num["4714"]["densidade"]
c["rend_pc_media"] = num["10295"]["rend_pc_media"]
c["rend_pc_mediana"] = num["10295"]["rend_pc_mediana"]
p = num["10300"]
c["pct_pobres"] = (p.p14_ate_1_4sm + p.p14_sem_rendimento) / p.p14_total * 100   # renda pc até 1/4 SM, incl. sem rendimento (pessoas 14+)
t = num["9517"]
c["desocup"] = t.desocupados / t.forca_trabalho * 100
c["alfabet"] = num["9543"]["taxa_alfabetizacao_15mais"]
u = num["9923"]
c["pct_urbana"] = u.pop_urbana / u.pop_total * 100
r = num["9605"]
c["pct_negra"] = (r.preta + r.parda) / r.pop_total * 100
h = num["9606"]
c["homens_15_29"] = h.homens_15_19 + h.homens_20_24 + h.homens_25_29
c.index.name = "cod_ibge"

# Checagens de consistência entre tabelas
chk = {
    "pop 4709 = 4714": int((num["4709"]["pop"] != num["4714"]["pop"]).sum()),
    "pop 4709 = 9923 total": int((num["4709"]["pop"] != u.pop_total).sum()),
    "pop 4709 = 9605 total": int((num["4709"]["pop"] != r.pop_total).sum()),
    "10300: soma das classes = total": int((p.drop(columns="p14_total").sum(axis=1) != p.p14_total).sum()),
    "9517: ocupados + desocupados = FT": int((t.ocupados + t.desocupados != t.forca_trabalho).sum()),
    "9923: urbana + rural = total": int((u.pop_urbana + u.pop_rural != u.pop_total).sum()),
}
print("Inconsistências (nº de municípios):", chk)
print("NAs nas covariáveis:", c.isna().sum()[c.isna().sum() > 0].to_dict())
c.reset_index().to_csv("tabelas/censo2022_municipios.csv", index=False)

# ---------------------------------------------------------------------------
# 3. TabNet / SIM
# ---------------------------------------------------------------------------
R = json.load(open("raw/tabnet_raw.json"))
GRUPOS = {"V01-V99": "transporte", "W00-X59": "outras_acidentais", "X60-X84": "suicidio", "X85-Y09": "agressao",
          "Y10-Y34": "intencao_indeterminada", "Y35-Y36": "intervencao_legal", "Y40-Y84": "complic_assist_medica",
          "Y85-Y89": "sequelas", "Total": "total_causas_externas"}

def tabnet(s):
    df = pd.read_csv(io.StringIO(html.unescape(s).strip()), sep=";", na_values=["-"]).fillna(0)
    c0 = df.columns[0]
    df.columns = [c0] + [next(v for k, v in GRUPOS.items() if col.startswith(k)) if any(col.startswith(k) for k in GRUPOS) else col
                         for col in df.columns[1:]]
    mun = df[df[c0].str.match(r"^\s*\d{6} ")].copy()
    ign = df[~df[c0].str.match(r"^\s*\d{6} ") & ~df[c0].str.contains("Total")].copy()
    tot = df[df[c0].str.contains("Total")].copy()
    mun.insert(0, "cod6", mun[c0].str.strip().str[:6].astype(int))
    mun.insert(1, "municipio_tabnet", mun[c0].str.strip().str[7:])
    mun = mun.drop(columns=c0)
    for k in mun.columns[2:]:
        mun[k] = mun[k].astype(int)
    return mun, ign, tot

out = {}
for k, nome in [("h2123", "sim_causas_externas_2021_2023"), ("h24", "sim_causas_externas_2024")]:
    mun, ign, tot = tabnet(R[k])
    mun.to_csv(f"tabelas/{nome}.csv", index=False)
    perdidos = int(ign.get("agressao", 0).sum() + ign.get("intervencao_legal", 0).sum())
    total = int(tot.agressao.sum() + tot.intervencao_legal.sum())
    print(f"{nome}: {len(mun)} municípios | homicídios total TabNet {total} | em 'município ignorado' {perdidos}")
    out[k] = mun
for k, nome in [("ama", "municipios_amazonia_legal"), ("fro", "municipios_faixa_fronteira")]:
    s = html.unescape(R[k]).strip()
    df = pd.read_csv(io.StringIO(s), sep=";")
    c0 = df.columns[0]
    df = df[df[c0].str.match(r"^\s*\d{6} ")]
    pd.DataFrame({"cod6": df[c0].str.strip().str[:6].astype(int), "municipio_tabnet": df[c0].str.strip().str[7:]}) \
        .to_csv(f"tabelas/{nome}.csv", index=False)

# ---------------------------------------------------------------------------
# 4. Base analítica
# ---------------------------------------------------------------------------
b = c.reset_index()
b["cod6"] = b.cod_ibge // 10
h = out["h2123"][["cod6", "agressao", "intervencao_legal", "intencao_indeterminada", "total_causas_externas"]]
h24 = out["h24"][["cod6", "agressao", "intervencao_legal"]].rename(columns=lambda x: x if x == "cod6" else x + "_24")
b = b.merge(h, on="cod6", how="left", validate="1:1").merge(h24, on="cod6", how="left", validate="1:1")
sem_linha = int(b.agressao.isna().sum())
cols0 = ["agressao", "intervencao_legal", "intencao_indeterminada", "total_causas_externas", "agressao_24", "intervencao_legal_24"]
b[cols0] = b[cols0].fillna(0).astype(int)          # TabNet omite municípios sem nenhuma morte externa -> zero
ama = set(pd.read_csv("tabelas/municipios_amazonia_legal.csv").cod6)
fro = set(pd.read_csv("tabelas/municipios_faixa_fronteira.csv").cod6)
b["amazonia_legal"] = b.cod6.isin(ama).astype(int)
b["faixa_fronteira"] = b.cod6.isin(fro).astype(int)

b["hom"] = b.agressao + b.intervencao_legal
b["hom_24"] = b.agressao_24 + b.intervencao_legal_24
b["exposure"] = b["pop"] * 3
b["taxa"] = b.hom / b.exposure * 1e5
b["taxa_24"] = b.hom_24 / b["pop"] * 1e5
b["log_rend"] = np.log(b.rend_pc_media)
b["desig"] = b.rend_pc_media / b.rend_pc_mediana
b["log_dens"] = np.log(b.dens)
b["pct_h1529"] = b.homens_15_29 / b["pop"] * 100
b["log_pop"] = np.log(b["pop"])
b["pct_indet"] = np.where(b.total_causas_externas > 0, b.intencao_indeterminada / b.total_causas_externas * 100, 0)
b.to_csv("tabelas/base_analitica.csv", index=False)

print(f"\nBase analítica: {len(b)} municípios | sem linha no TabNet (zero óbitos externos): {sem_linha}")
print("NAs:", b.isna().sum()[b.isna().sum() > 0].to_dict())
print(f"Homicídios 2021–23: {b.hom.sum()} | 2024: {b.hom_24.sum()} | taxa BR: {b.hom.sum()/b.exposure.sum()*1e5:.2f}")
print(f"Amazônia Legal: {b.amazonia_legal.sum()} | Faixa de fronteira: {b.faixa_fronteira.sum()}")

dic = {
    "cod_ibge": "Código IBGE do município (7 dígitos)", "cod6": "Código IBGE sem dígito verificador (usado no DATASUS)",
    "municipio": "Nome do município", "uf": "Sigla da UF", "regiao": "Região (N, NE, CO, SE, S)",
    "pop": "População residente, Censo 2022 (SIDRA 4709)", "area_km2": "Área territorial em km² (SIDRA 4714)",
    "dens": "Densidade demográfica, hab/km² (SIDRA 4714)",
    "rend_pc_media": "Rendimento domiciliar per capita médio, R$ (SIDRA 10295)",
    "rend_pc_mediana": "Rendimento domiciliar per capita mediano, R$ (SIDRA 10295)",
    "pct_pobres": "% de pessoas de 14+ anos com renda domiciliar per capita até 1/4 SM ou sem rendimento (SIDRA 10300)",
    "desocup": "Taxa de desocupação, % da força de trabalho (SIDRA 9517)",
    "alfabet": "Taxa de alfabetização, 15+ anos, % (SIDRA 9543)", "pct_urbana": "% da população em situação urbana (SIDRA 9923)",
    "pct_negra": "% da população preta ou parda (SIDRA 9605)", "homens_15_29": "Homens de 15 a 29 anos (SIDRA 9606)",
    "agressao": "Óbitos por agressão X85–Y09, 2021–2023, por residência (SIM)",
    "intervencao_legal": "Óbitos por intervenção legal Y35–Y36, 2021–2023 (SIM)",
    "intencao_indeterminada": "Óbitos de intenção indeterminada Y10–Y34, 2021–2023 (SIM)",
    "total_causas_externas": "Total de óbitos por causas externas, 2021–2023 (SIM)",
    "agressao_24": "Óbitos por agressão, 2024 (SIM)", "intervencao_legal_24": "Óbitos por intervenção legal, 2024 (SIM)",
    "amazonia_legal": "1 se o município pertence à Amazônia Legal", "faixa_fronteira": "1 se está na faixa de fronteira",
    "hom": "Homicídios 2021–2023 = agressao + intervencao_legal", "hom_24": "Homicídios 2024",
    "exposure": "Pessoas-ano de exposição = 3 × pop", "taxa": "Taxa de homicídios por 100 mil hab./ano, 2021–2023",
    "taxa_24": "Taxa de homicídios por 100 mil hab., 2024", "log_rend": "ln(rend_pc_media)",
    "desig": "Razão média/mediana do rendimento per capita (proxy de desigualdade)", "log_dens": "ln(dens)",
    "pct_h1529": "% de homens de 15 a 29 anos na população", "log_pop": "ln(pop)",
    "pct_indet": "% de óbitos de intenção indeterminada no total de causas externas"}
pd.DataFrame({"coluna": list(dic), "descricao": list(dic.values())}).to_csv("tabelas/dicionario.csv", index=False)
