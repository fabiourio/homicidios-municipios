# Revisão final do modelo — 17/11/2026

O modelo funciona e os cálculos publicados foram reproduzidos sem divergência numérica relevante.
Ele permite discutir associações municipais, com inferência exploratória e limitações explícitas.
A revisão não autoriza conclusões causais nem uma promessa de previsão para novos municípios.

## O que foi validado

| Verificação | Evidência | Consequência |
|---|---|---|
| Amostra e execução | 1.133 municípios, 14 parâmetros, 1.119 graus de liberdade; sem faltantes no ajuste | Modelo identificável e resultados finitos |
| Mesma base na exploratória e no modelo | Mesmos 1.133 códigos municipais | Gráficos e ajuste compartilham o recorte |
| Reconstrução independente da amostra integrada | Diferença máxima dos coeficientes igual a zero | Integração e centralização reproduzidas |
| Coeficientes, efeitos e intervalos | Diferenças inferiores a 0,0000000001 | Fórmulas reproduzidas, incluindo covariância da interação |
| Fontes locais de variáveis extras | 44.560 comparações sem divergência, na auditoria anterior | Dados integrados conferem com os arquivos originais disponíveis |
| Ajuste | R² ajustado 0,5585 na escala ln(taxa) | Não representa 55,85% da variação na taxa original |
| Variância dos erros | Gráfico e Breusch–Pagan, p = 0,0000144 | A variância não constante permanece |
| Normalidade dos resíduos padronizados | Q–Q e Shapiro–Wilk, p = 0,1652 | Não houve rejeição; isso não prova normalidade |
| Independência espacial | Não verificada | Dependência entre municípios pode afetar a inferência |
| PRESS | 315,0406; 1 − PRESS/SST = 0,5521 | Diagnóstico de retirada de uma observação, condicional à especificação |

O PRESS foi conferido por 1.133 reajustes diretos, retirando um município por vez.
Ele não valida a seleção anterior das variáveis, dependência espacial ou previsão fora deste contexto.
Os intervalos clássicos continuam condicionais às hipóteses que a heteroscedasticidade coloca em dúvida.

## Decisões revistas

**Resposta e ODS.** A taxa anual média usa agressões e intervenções legais/operações de guerra do SIM em 2021–2023.
A população de 2022 aproxima a exposição durante três anos.
Essa definição se relaciona à ODS 16, mas não equivale exatamente ao indicador internacional 16.1.1.
Não usar uma razão direta contra a taxa mundial de homicídio intencional.

**Recorte de 30 mil habitantes.** O recorte reduz instabilidade em taxas de contagens pequenas, sem resolver toda a variância desigual.
Ele restringe as conclusões aos municípios incluídos. Os testes não demonstram que esse corte seja ótimo.
Nos cortes de 20, 50 e 100 mil, as principais direções de Gini e escola persistem.
Os intervalos e magnitudes mudam; frequência escolar deixa de se distinguir de zero no corte de 100 mil.
Não escolher o corte pelo menor valor p ou pelo melhor teste de normalidade.

**Campos do Jordão e Nova Lima.** A exclusão de Campos foi mantida pela suspeita documentada de classificação dos óbitos.
Um homicídio e 36 óbitos indeterminados não comprovam erro de registro nem homicídios ocultos.
Reincluir Campos preserva as principais direções, mas o p de Shapiro muda de 0,1652 para 0,0011.
Isso mostra sensibilidade do diagnóstico; não serve como justificativa para excluir o município.
Retirar Nova Lima isoladamente preserva as principais estimativas.
O efeito de +0,05 no Gini, na renda mediana, passa de +15,78% para +15,94%.
O efeito de +5 pontos percentuais na frequência passa de −8,63% para −8,60%.

**Região ou estado.** Manter região é coerente com a pergunta e com uma apresentação curta, usando menos parâmetros.
O modelo com estado melhora o R² ajustado para 0,6378 e reduz as magnitudes de Gini e escola.
Na mesma renda mediana, o efeito do Gini passa de +15,78% para +6,39%.
Logo, os efeitos dependem do controle geográfico; não são valores universais.
O PRESS do modelo com estado não foi definido: Brasília é a única observação do Distrito Federal.
Retirá-la elimina esse nível, impedindo sua previsão pela mesma especificação categórica.

**Renda, Gini e VIF.** O termo quadrático e a interação representam associações que variam com a renda.
Os termos principais permanecem junto aos termos derivados, respeitando a hierarquia do modelo.
Centralizar facilita a interpretação; minimizar o VIF não substitui o diagnóstico dos erros.
O VIF máximo de 7,61 não certifica a qualidade do modelo nem demonstra a causa de um sinal inesperado.

**Transformação.** Box-Cox foi repetido com os mesmos termos da especificação final.
A potência estimada foi 0,174, com intervalo aproximado de 0,117 a 0,232, pela grade avaliada.
Zero, correspondente ao log, continua fora desse intervalo.
O log permanece uma escolha de interpretação e diagnóstico visual, sem ser a potência ótima selecionada.
O apêndice C foi atualizado. Trocar a transformação exigiria refazer estimativas, gráficos e conclusões.
Não foi feita essa troca para melhorar um teste isolado.

**Hipóteses.** H1 depende da renda. H2 trata de exclusão escolar, sem medir exclusão social em geral.
H3 foi testada e não recebeu apoio claro no ajuste final; migração continua como covariável.
A retirada da medida de intenção indeterminada, matematicamente acoplada à resposta, mudou o apoio a H3.
As comparações controladas estão em `saida/08_sensibilidade_migracao.csv`.
Migração significa residência inferior a dez anos, sem restrição à origem internacional.
Ausência de evidência clara não comprova ausência de associação.

## Conclusões permitidas na apresentação

- Escolarização, desigualdade, renda e região apresentam associações condicionais no ajuste.
- A associação do Gini varia com a renda; o resultado não sustenta um efeito positivo uniforme.
- A migração recente não recebeu apoio claro no modelo final.
- Os percentuais descrevem a taxa típica derivada do ajuste em log, sem representar uma média aritmética.
- A variância desigual, o possível sub-registro, o Gini aproximado e a dependência espacial limitam a interpretação.
- Estudos futuros podem avaliar variância desigual, estrutura espacial e estabilidade em outras bases e períodos.

A apresentação principal usa 14 slides e 13min30 planejados.
Kauan dispõe de 1min45 para contexto, ODS 16, meta 16.1 e indicador de referência 16.1.1.
Os nove apêndices são apoio para perguntas, sem leitura obrigatória.
O ensaio humano ainda precisa confirmar a duração.

## Reprodução

Na raiz do repositório:

```sh
/Library/Frameworks/R.framework/Resources/bin/Rscript validacao/auditar_modelo.R
```

O script executa os dois códigos finais e regenera seus resultados, sem alterar dados ou especificação.
Ele registra 365 medidas e comparações em `saida/09_auditoria_modelo.csv` e `.txt`.
As afirmações numéricas acima podem ser conferidas nesses arquivos.
A revisão das fontes está em `saida/07_extras_fontes.txt`; o contexto geral está em `RELATORIO.md`.

## Auditoria posterior das candidatas

A [auditoria adicional](AUDITORIA_CANDIDATAS.md) examinou as candidatas disponíveis, incluindo estrutura familiar e despesas reconstruídas.
Algumas alternativas acrescentam informação e alteram magnitudes ou a evidência da migração.
A [verificação de favelas](FAVELAS_METODO_E_DECISAO.md) registra a fonte oficial e as sensibilidades.
O usuário confirmou manter a especificação principal e guardar essas comparações como apoio.
Isso não demonstra que a especificação adotada seja única ou ótima.
