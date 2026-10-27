"""
Baixa os dados brutos das fontes oficiais e grava em dados/raw/ e dados/.

  1. SIDRA/IBGE (Censo 2022)  -> dados/raw/sidra_raw.json
  2. TabNet/DATASUS (SIM)      -> dados/raw/tabnet_raw.json
  3. Malha municipal do IBGE   -> dados/malha_mun.geojson

Os arquivos já estão no repositório, então este script só precisa ser rodado
para atualizar ou conferir os dados. Leva alguns minutos.

Uso:  python scripts/00_coletar_dados.py            (baixa tudo)
      python scripts/00_coletar_dados.py sidra      (só uma parte: sidra | tabnet | malha)
"""
import json, re, sys, time
from pathlib import Path
from urllib.parse import quote
import requests

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "dados" / "raw"
RAW.mkdir(parents=True, exist_ok=True)
S = requests.Session()
S.headers["User-Agent"] = "projeto-academico-regressao/1.0"

UFS = [11, 12, 13, 14, 15, 16, 17, 21, 22, 23, 24, 25, 26, 27, 28, 29, 31, 32, 33, 35, 41, 42, 43, 50, 51, 52, 53]


def get(url, **kw):
    for tentativa in range(5):
        try:
            r = S.get(url, timeout=120, **kw)
            r.raise_for_status()
            return r
        except requests.RequestException as e:
            print(f"   falhou ({e}); tentando de novo...")
            time.sleep(3 * (tentativa + 1))
    raise RuntimeError(f"não consegui baixar {url}")


# ---------------------------------------------------------------------------
# 1. SIDRA — tabelas do Censo 2022, por município (consulta feita UF por UF)
# ---------------------------------------------------------------------------
SIDRA = [  # (tabela, variáveis, classificações)
    ("4709", "93", ""),                                                            # população
    ("4714", "93|6318|614", ""),                                                   # pop, área, densidade
    ("10295", "13604|13431|13534", "2[6794]|86[95251]|58[95253]"),                 # renda pc média e mediana
    ("10300", "13432", "629[32385]|386[all]"),                                     # pessoas 14+ por classe de renda pc
    ("9517", "1641", "629[32385,32386,32387,32446,32447]|2[6794]|86[95251]|1568[120704]"),  # força de trabalho
    ("9543", "2513", "2[6794]|86[95251]|287[100362]"),                             # taxa de alfabetização
    ("9923", "93", "1[6795,1,2]"),                                                 # situação urbana/rural
    ("9605", "93", "86[95251,2776,2777,2778,2779,2780]"),                          # cor ou raça
    ("9606", "93", "86[95251]|2[4]|287[93086,93087,93088]"),                       # homens 15–29
]


def coletar_sidra():
    base = "https://servicodados.ibge.gov.br/api/v3/agregados/"
    out = {}
    for t, v, c in SIDRA:
        print(f"SIDRA {t}...")
        cols, idx, data = [], {}, {}
        for uf in UFS:
            url = f"{base}{t}/periodos/2022/variaveis/{v}?localidades=N6[N3[{uf}]]" + (f"&classificacao={c}" if c else "")
            for V in get(url).json():
                for R in V["resultados"]:
                    lab = f"v{V['id']} {V['variavel']}"
                    if R["classificacoes"]:
                        lab += " | " + " | ".join(f"{k['nome']}={list(k['categoria'].values())[0]}" for k in R["classificacoes"])
                    lab += f" [{V['unidade']}]"
                    if lab not in idx:
                        idx[lab] = len(cols); cols.append(lab)
                    for s in R["series"]:
                        reg = data.setdefault(s["localidade"]["id"], {"nome": s["localidade"]["nome"], "v": {}})
                        reg["v"][idx[lab]] = s["serie"]["2022"]
        rows = [[i, r["nome"]] + [r["v"].get(k) for k in range(len(cols))] for i, r in data.items()]
        out[t] = {"cols": cols, "rows": rows,
                  "url": f"{base}{t}/periodos/2022/variaveis/{v}?localidades=N6[all]" + (f"&classificacao={c}" if c else "")}
        print(f"   {len(cols)} colunas, {len(rows)} municípios")
    (RAW / "sidra_raw.json").write_text(json.dumps(out, ensure_ascii=False), encoding="utf-8")


# ---------------------------------------------------------------------------
# 2. TabNet — óbitos por causas externas (SIM), por município de residência
#    O formulário do TabNet espera os campos codificados em Latin-1.
# ---------------------------------------------------------------------------
TABNET = "http://tabnet.datasus.gov.br/cgi/tabcgi.exe?sim/cnv/ext10br.def"
FILTROS = ["SMunicípio", "SCapital", "SRegião_de_Saúde_(CIR)", "SMacrorregião_de_Saúde", "SMicrorregião_IBGE",
           "SRegião_Metropolitana_-_RIDE", "STerritório_da_Cidadania", "SMesorregião_PNDR", "SAmazônia_Legal", "SSemiárido",
           "SFaixa_de_Fronteira", "SZona_de_Fronteira", "SMunicípio_de_extrema_pobreza", "SGrande_Grupo_CID10",
           "SGrupo_CID10", "SCategoria_CID10", "SFaixa_Etária", "SFaixa_Etária_OPS", "SFaixa_Etária_det",
           "SFx.Etária_Menor_1A", "SSexo", "SCor/raça", "SEscolaridade", "SEstado_civil", "SLocal_ocorrência",
           "SAcid._Trabalho"]


def tabnet(coluna, anos, filtros=None):
    filtros = filtros or {}
    campos = [("Linha", "Município"), ("Coluna", coluna), ("Incremento", "Óbitos_p/Residênc")]
    campos += [("Arquivos", f"extbr{a % 100:02d}.dbf") for a in anos]
    for f in FILTROS:
        for val in filtros.get(f, ["TODAS_AS_CATEGORIAS__"]):
            campos.append((f, val))
    campos += [("formato", "prn"), ("mostre", "Mostra")]
    corpo = "&".join(f"{quote(k, encoding='latin-1', safe='')}={quote(v, encoding='latin-1', safe='')}" for k, v in campos)
    r = S.post(TABNET, data=corpo.encode("ascii"), timeout=300,
               headers={"Content-Type": "application/x-www-form-urlencoded"})
    r.raise_for_status()
    m = re.search(r"<PRE>(.*?)</PRE>", r.content.decode("latin-1"), re.S | re.I)
    if not m:
        raise RuntimeError("TabNet não devolveu tabela (o formulário pode ter mudado).")
    return re.sub(r"<[^>]+>", "", m.group(1))


def coletar_tabnet():
    out = {}
    print("TabNet 2021–2023..."); out["h2123"] = tabnet("Grande_Grupo_CID10", [2021, 2022, 2023])
    print("TabNet 2024...");      out["h24"] = tabnet("Grande_Grupo_CID10", [2024])
    anos = list(range(2010, 2025))  # para listar municípios, qualquer óbito externo no período basta
    print("TabNet Amazônia Legal..."); out["ama"] = tabnet("--Não-Ativa--", anos, {"SAmazônia_Legal": ["1"]})
    print("TabNet faixa de fronteira..."); out["fro"] = tabnet("--Não-Ativa--", anos, {"SFaixa_de_Fronteira": ["1"]})
    (RAW / "tabnet_raw.json").write_text(json.dumps(out, ensure_ascii=False), encoding="utf-8")


# ---------------------------------------------------------------------------
# 3. Malha municipal (GeoJSON, qualidade mínima — suficiente para mapas e vizinhança)
# ---------------------------------------------------------------------------
def coletar_malha():
    print("Malha municipal...")
    url = ("https://servicodados.ibge.gov.br/api/v3/malhas/paises/BR"
           "?intrarregiao=municipio&formato=application/vnd.geo%2Bjson&qualidade=minima")
    (ROOT / "dados" / "malha_mun.geojson").write_bytes(get(url).content)


if __name__ == "__main__":
    partes = sys.argv[1:] or ["sidra", "tabnet", "malha"]
    if "sidra" in partes:  coletar_sidra()
    if "tabnet" in partes: coletar_tabnet()
    if "malha" in partes:  coletar_malha()
    print("Pronto. Rode agora: python scripts/01_preparar_dados.py")
