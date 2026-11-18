# Revisão da narrativa da apresentação

Pedidos do usuário em 17/11/2026: retirar os apêndices de referências, retirar o rodapé repetido e verificar hipóteses e tempo.
O usuário também pediu que cada slide cumpra um dos cinco itens das professoras.

## Encaminhamento

- Manter região no modelo principal, conforme confirmação reiterada do usuário em 17/11.
- Preservar os cinco apresentadores e sua ordem.
- Preservar 14 slides principais e a meta total de 13min30.
- Reservar 105 segundos para Kauan. O acréscimo de 30 segundos contextualiza ODS, meta e indicador. O tempo dos demais permanece igual.
- Definir o tempo como meta e limite de ensaio, sem exigir preencher segundos com leitura.
- Retirar da abertura a conclusão sobre diferenças regionais. A comparação internacional e a escala das mortes na base motivam a pergunta. A abertura liga esses dados à meta 16.1 da ODS 16.
- Manter a pergunta de associação do estudo. As hipóteses iniciais ficam no briefing e retornam na discussão dos resultados.
- Não trocar uma hipótese apenas porque ela não recebeu apoio.
- Usar exclusão escolar, medida por frequência e atraso escolar. Não chamar essa medida de exclusão social em geral.
- Usar migração recente, não imigração internacional. A medida é residência ininterrupta inferior a dez anos.
- Retirar os dois apêndices de referências e retirar as fontes visíveis da projeção. Preservar referências na documentação.
- Retirar GED-16 e o título repetidos no rodapé. Preservar a numeração.
- Retirar os dois gráficos exploratórios do corpo. As figuras permanecem disponíveis no repositório.
- Organizar as cinco partes exatamente na sequência do enunciado docente.

## Função de cada slide

| Slide | Item docente | Pessoa | Segundos | Função |
|---|---|---|---:|---|
| 1 | Contextualização | Kauan | 10 | Apresentar tema e grupo |
| 2 | Contextualização e questão | Kauan | 95 | Definir ODS, ODS 16, meta 16.1, indicador 16.1.1, dimensão do problema e pergunta |
| 3 | Base de dados | Fabio | 40 | Informar fontes, período e medida da resposta |
| 4 | Base de dados | Fabio | 50 | Delimitar recorte e grupos de variáveis |
| 5 | Metodologia | Douglas | 55 | Explicar o modelo e a finalidade dos termos |
| 6 | Metodologia | Douglas | 65 | Explicar a finalidade dos procedimentos de avaliação |
| 7 | Ajuste do modelo | Luiz Felipe | 60 | Mostrar o ajuste observado, a escala e seu alcance |
| 8 | Ajuste do modelo | Luiz Felipe | 65 | Interpretar os erros e a variância não constante |
| 9 | Ajuste do modelo | Luiz Felipe | 55 | Interpretar a distribuição dos resíduos |
| 10 | Discussão e interpretação | Willian | 65 | Interpretar escola, urbanização e migração |
| 11 | Discussão e interpretação | Willian | 70 | Interpretar a associação do Gini conforme a renda |
| 12 | Discussão e interpretação | Willian | 55 | Interpretar renda e região no ajuste |
| 13 | Discussão e interpretação | Willian | 65 | Delimitar as conclusões e reconhecer limitações |
| 14 | Discussão e interpretação | Willian | 60 | Responder à pergunta e propor trabalhos futuros |

Totais: Kauan 105s; Fabio 90s; Douglas 120s; Luiz Felipe 180s; Willian 315s. Total 810s.
A abertura passa a 3min15. Permanecem 1min30 de reserva até o limite de 15 minutos.

## O que ocorreu com a hipótese de migração

O registro de 11/11 mostra que H3 deixou de receber apoio após a retirada da medida problemática de intenção indeterminada.
A migração continua no modelo; não foi retirada junto com fronteira, abandono escolar e proporção de homens jovens.

Uma comparação controlada foi refeita em uma cópia temporária, mantendo os demais termos do ajuste final:

| Especificação | Coeficiente da migração | p clássico |
|---|---:|---:|
| Modelo final | 0,004062384 | 0,14333404 |
| Acrescentando a medida antiga de intenção indeterminada | 0,005605432 | 0,04302121 |
| Acrescentando a medida corrigida | 0,004060676 | 0,14680359 |

Esses não são os resultados exatos da apresentação parcial: são comparações com a mesma especificação final.
A mudança mostra dependência de uma variável que tinha acoplamento matemático com a resposta.
O teste não comprova ausência de associação nem explica um mecanismo causal.
A variância não constante exige cautela com esses valores p clássicos.

Formulação para a fala: “Também testamos a migração recente, mas não encontramos evidência clara no modelo final.”
A interpretação aparece nos slides 10 e 14. A história da correção fica no briefing para perguntas.

Reprodução, na pasta `entrega/`, preferencialmente em uma cópia temporária:

```r
source("2_modelo.R")
summary(final)$coefficients["pct_migr_10anos", ]
summary(update(final, . ~ . + pct_indet))$coefficients["pct_migr_10anos", ]
summary(update(final, . ~ . + indet_sem_hom))$coefficients["pct_migr_10anos", ]
```

Nenhum dado ou coeficiente do modelo principal foi alterado nesta revisão.

A comparação controlada está preservada em `validacao/saida/08_sensibilidade_migracao.csv`.
O ajuste principal continua com os mesmos 14 parâmetros, municípios e coeficientes.

## Contextualização da ODS — ajuste final solicitado pelo Kauan

Kauan assume a definição de ODS e a ligação do projeto com a Agenda 2030.
A fala define ODS; o slide 2 nomeia a ODS 16 e apresenta a meta 16.1 e o indicador de referência 16.1.1.
A medida do estudo é relacionada ao indicador, sem reproduzi-lo exatamente: inclui X85–Y09 e Y35–Y36 e usa média de 2021–2023.
A comparação internacional começa na taxa mundial e passa à brasileira, ambas de 2021.
A contagem de 46.105 por ano é média de 2021–2023 na base nacional, não da amostra final.
Não foi demonstrado que 2021 seja um ano atípico. O destaque é a diferença Brasil–mundo no mesmo ano.
O slide 2 recebe 95 segundos; Kauan totaliza 105. Os tempos dos demais não mudam.
O total de 810 segundos preserva 90 segundos de margem até o limite de quinze minutos.

Fontes oficiais: [ONU Brasil — ODS](https://brasil.un.org/pt-br/sdgs), [ODS 16 e meta 16.1](https://brasil.un.org/pt-br/sdgs/16), [metadados 16.1.1](https://unstats.un.org/sdgs/metadata/files/Metadata-16-01-01.pdf).
