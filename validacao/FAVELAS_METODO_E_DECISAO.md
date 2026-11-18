# Favelas e comunidades urbanas: verificação e decisão final

## O que a variável mede

`pct_favela = 100 × população residente em Favelas e Comunidades Urbanas / população municipal de 2022`.

O numerador vem da tabela SIDRA 9888, variável 9612, ano 2022. São pessoas, não área, número de favelas ou número de domicílios. O denominador vem do Censo 2022. A observação continua sendo o município.

O IBGE identifica esses territórios por critérios de posse e características urbanísticas e de infraestrutura. A classificação não se baseia em homicídios. Portanto, ela não foi construída a partir da nossa resposta.

## Conferência realizada

- Consulta atual à API oficial em 17/11/2026, comparada com a captura local.
- 656 códigos municipais únicos; todas as contagens iguais; sem valores suprimidos entre os registros retornados.
- Total corrigido de 16.390.790 residentes, compatível com a publicação retificada do IBGE.
- Percentuais recalculados para os 5.570 municípios, sem divergência relevante em relação à base integrada.
- No recorte de 1.133 municípios: 509 com população nessas áreas e 624 sem áreas identificadas na tabela.
- Nenhum percentual faltante ou fora de 0 a 100. Maior percentual: cerca de 60,17%.

A ausência na tabela foi codificada como zero de população em áreas identificadas pelo Censo. Isso não demonstra ausência de qualquer ocupação informal não mapeada. O dado não mede pobreza individual, crime dos moradores ou todos os aspectos da infraestrutura.

## O que acontece ao acrescentar a variável

Mesmos 1.133 municípios, mesmos termos anteriores, região mantida:

| Medida | Modelo principal | Com percentual de favelas |
|---|---:|---:|
| R² ajustado | 0,5585 | 0,5638 |
| PRESS, especificação fixa | 315,04 | 311,49 |
| Shapiro–Wilk, p | 0,1652 | 0,0619 |
| Breusch–Pagan, p | 0,0000144 | 0,0000639 |

O coeficiente adicional é 0,008518. Para +10 pontos percentuais, a associação estimada na taxa típica é +8,9%, com intervalo clássico de 95% de +4,2% a +13,8%. O teste de contribuição adicional tem p clássico de 0,000142.

A forma log1p também apresentou evidência, mas muda a interpretação e foi tratada apenas como alternativa. Não escolhemos uma transformação pelo menor p.

## Limites da estabilidade

- O sinal permanece positivo ao retirar cada uma das 27 UFs, uma por vez, mantendo região no ajuste.
- O sinal também permanece positivo ao retirar cada região, uma por vez.
- Com população mínima de 100 mil, o intervalo passa a incluir zero: p clássico próximo de 0,080.
- No comparativo com estados, o coeficiente cai e apresenta p próximo de 0,115.
- O controle adicional por logaritmo da população mantém a associação positiva, mas não prova causalidade.
- Uma indicadora de presença de favela acrescentada junto do percentual sugere que a forma da relação merece investigação.
- A variância desigual continua. Os testes e intervalos clássicos permanecem exploratórios.

O comparativo com estados é apenas sensibilidade. A decisão por região foi preservada. A perda de evidência em outro controle não prova efeito zero no regional; mostra dependência da especificação.

## Decisão nesta entrega

Manter o modelo principal adotado e guardar favelas como comparação documentada. O usuário confirmou esse caminho após a auditoria. A discussão posterior reforçou a necessidade de cautela antes de alterar o modelo no fechamento.

A fonte é adequada para a proporção mapeada. A contribuição existe no modelo regional, mas o ganho é modesto e a interpretação é sensível ao controle geográfico, ao recorte e à forma funcional. Não afirmar que a candidata foi descartada por dados não confiáveis ou por ausência de significância.

Essa é uma decisão atual de escopo, interpretação e estabilidade. Não é uma reconstrução de uma exclusão estatística anterior. O modelo principal também não é apresentado como único ou ótimo.

## Outras inclusões cogitadas

Participação industrial e ln(PIB por habitante) também acrescentam informação isoladamente. Com favelas, indústria e PIB juntos, o R² ajustado passa a 0,5693. Porém, o p clássico do PIB passa a aproximadamente 0,087 e o da indústria a 0,049. As contribuições se sobrepõem e dependem dos controles. Não acrescentamos as três apenas pelos testes individuais.

## Reprodução e evidências

Na raiz: `Rscript validacao/verificar_favelas.R`.

O script verifica a captura oficial versionada, reconstrói os percentuais e executa as comparações. As saídas estão em `validacao/saida/12_favela_*`. A consulta online foi registrada como captura; o script não exige internet para reproduzir os cálculos.

API: <https://apisidra.ibge.gov.br/values/t/9888/n6/all/v/9612/p/2022?formato=json>.

Definição: [Quadro Geográfico de Referência do IBGE](https://www.ibge.gov.br/apps/quadrogeografico/pdf/qg_2022_670_fcu.pdf).

Publicação retificada: [Apresentação oficial do IBGE, 17/04/2025](https://ftp.ibge.gov.br/Censos/Censo_Demografico_2022/Favelas_e_comunidades_urbanas_Resultados_do_universo/Anexos/FavelasComunidadesUrbanas_Apresentacao_20250417.pdf).
