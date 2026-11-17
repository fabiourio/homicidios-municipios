# Revisão do projeto com a apostila e as orientações docentes

Data: 17/11/2026. Apresentação final: 18/11/2026.

## Conclusão prática

A revisão da narrativa define 23 páginas: 14 slides principais e nove apêndices, A–I.
O verificador confirmou 23 páginas, cinco briefings, notas iguais e roteiro de 780 segundos.
A [revisão da narrativa](revisao-semantica-apresentacao.md) registra os pedidos posteriores do usuário em 17/11.
Não resta decisão aberta sobre região, divisão de falas, vizinhança ou organização dos slides.
O ensaio cronometrado do grupo ainda precisa confirmar a duração real.
O projeto completo ainda precisa do artigo, do código final em `.qmd` e do ZIP de entrega.
O responsável pelo envio precisa ser identificado na mensagem da atividade.

A revisão não encontrou divergência que justifique alterar os dados ou trocar o modelo final.
A [auditoria computacional final](../validacao/REVISAO_MODELO_FINAL.md) reproduziu efeitos e avaliou cenários de sensibilidade.
A variância não constante continua sendo uma limitação conhecida, exposta nos materiais.
Não foi declarada como problema resolvido.

## O que foi conferido

- Scripts de coleta, preparação, integração das variáveis usadas, análise e validação.
- Bases e dicionários que alimentam a análise final.
- Fontes locais originais de frequência escolar, distorção escolar, abandono e migração.
- Especificação, transformação da resposta, testes, diagnóstico e interpretação do modelo.
- Slides, falas, briefings e correspondência das exportações.
- Relatório exploratório antigo e modelo do artigo fornecido pela professora.
- Instruções escritas, transcrição do alinhamento e decisões do grupo.

Os demais candidatos históricos não foram baixados novamente nem usados para escolher outro modelo nesta revisão.
A revisão não revalidou integralmente todos os artigos da biblioteca de literatura.
As referências efetivamente usadas na apresentação foram confrontadas com o registro bibliográfico do projeto.

## Apostila consultada

Fonte oficial: [Introdução a Modelos de Regressão — Denise Ferrari, ITA](https://www.ief.ita.br/~denise/GED16/Apostila/).
A consulta foi feita diretamente ao site oficial, sem depender dos antigos resumos do repositório.

| Tema | Base na apostila | Situação no projeto |
|---|---|---|
| Diagnóstico por gráficos | [Cap. 4, seção 4.4](https://www.ief.ita.br/~denise/GED16/Apostila/rls-residuos.html) | Resíduos, histograma e quantis estão no corpo. Gráficos contra cada explicativa foram acrescentados nos apêndices H e I (páginas 22–23) |
| Variância não constante | [Cap. 4, seções 4.5–4.6](https://www.ief.ita.br/~denise/GED16/Apostila/rls-residuos.html) | Limitação reconhecida. Transformações ou mínimos quadrados ponderados são alternativas da própria apostila |
| Transformação da resposta | [Cap. 4, seção 4.7](https://www.ief.ita.br/~denise/GED16/Apostila/rls-residuos.html) | O log foi escolhido por interpretação e gráficos. Box-Cox auxiliar e final não escolheram potência zero |
| Regressão múltipla, testes e intervalos | [Cap. 5](https://www.ief.ita.br/~denise/GED16/Apostila/rlm.html) | Modelo e testes correspondem à resposta ln(taxa). A cautela com os intervalos clássicos permanece |
| Contribuição dos termos | [Cap. 6, seção 6.1](https://www.ief.ita.br/~denise/GED16/Apostila/rlm-topicos.html) | Testes F parciais documentados. Não confundir uma não rejeição com prova de efeito zero |
| Multicolinearidade | [Cap. 6, seções 6.2–6.5](https://www.ief.ita.br/~denise/GED16/Apostila/rlm-topicos.html) | O VIF não substitui o diagnóstico. A troca de sinal da desocupação não demonstra sua causa |
| Curvatura, interação e hierarquia | [Cap. 7, seção 7.4](https://www.ief.ita.br/~denise/GED16/Apostila/rlm-construcao.html) | Renda, quadrado e Gini × renda são preservados e retirados conjuntamente na comparação auxiliar |
| Variável categórica | [Cap. 7, seções 7.5–7.6](https://www.ief.ita.br/~denise/GED16/Apostila/rlm-construcao.html) | Região entra como fator. O Sudeste é a referência |
| PRESS e validação deixando uma observação fora | [Cap. 8, seção 8.1](https://www.ief.ita.br/~denise/GED16/Apostila/rlm-selecao-variaveis.html) | Estão na apostila. Uma seleção nova não foi exigida nem iniciada nesta revisão |
| Independência | [Cap. 4, seção 4.4 e exemplo 4.8](https://www.ief.ita.br/~denise/GED16/Apostila/rls-residuos.html) | Durbin-Watson aparece na apostila, mas não resolve uma vizinhança artificial por código IBGE. O pedido docente de retirar esse teste foi preservado |

O GVIF e os demais cálculos não descritos explicitamente continuam identificados como escolhas do grupo no material de apoio.
A matriz de covariâncias apresentada na apostila fundamenta combinações lineares, mas não torna a heteroscedasticidade resolvida.
Não introduzimos métodos novos para buscar testes favoráveis.

## Correções feitas na revisão com a apostila

1. Acrescentamos resíduos contra renda, Gini, desocupação, urbanização, escola, migração e região.
2. Preservamos os 14 slides principais e o roteiro de 13 minutos; os painéis novos são apoio para perguntas.
3. Explicitamos que o Gini calculado considera pessoas de 14 anos ou mais.
4. Explicitamos que a referência oficial do Gini considera todos os moradores.
5. Corrigimos valores e afirmações desatualizados do relatório de validação.
6. Registramos a conferência das variáveis extras contra os arquivos originais.
7. Preparamos uma pasta portátil para o grupo, com arquivos e instruções que não dependem da estrutura do repositório.

## Atualização da narrativa em 17/11

- Manter a sequência docente: contexto, dados, metodologia, ajuste e discussão.
- Retirar os dois gráficos exploratórios do corpo e preservar as figuras no repositório.
- Mostrar taxas observadas e ajustadas no slide 7.
- Retirar os dois apêndices de referências e manter as fontes curtas dos gráficos.
- Manter apenas a numeração no rodapé. Renomear os diagnósticos complementares como H e I.
- Reservar 75/90/120/180/315 segundos, na mesma ordem dos cinco apresentadores.
- Preservar hipóteses como expectativas iniciais, com discussão posterior dos resultados.

A abertura cobre problema e pergunta em 2min45, incluindo os dados. O último slide recebe 60 segundos.
H2 mede exclusão escolar por frequência e atraso escolar. Não mede exclusão social em geral.
H3 mede migração recente por residência ininterrupta inferior a dez anos. Não mede imigração internacional.
A migração permanece no modelo, com p clássico de 0,143, sem evidência clara de associação.
A retirada da medida problemática de intenção indeterminada mudou o apoio a H3 no registro de 11/11.
Nenhum dado ou coeficiente do modelo principal muda nesta atualização.
A verificação dos novos materiais fica registrada separadamente em [VERIFICACAO.md](../apresentacao/VERIFICACAO.md).

## Conferência dos dados

Os scripts 01 e 03 reconstruíram as bases em uma cópia isolada.
Os quatro CSVs verificados permaneceram iguais aos originais, pela comparação de seus valores.
Há 5.570 códigos municipais únicos; as junções do SIM e do Censo não deixaram chaves quebradas.

Nas fontes de educação e migração, foram comparadas 44.560 células, sem divergências, com tolerância de 1e-10.
Os sete valores ausentes do INEP ficam fora do recorte do modelo.
A frequência é uma taxa bruta. A migração mede residência ininterrupta inferior a dez anos, não um fluxo anual.
A reprodução específica está em `validacao/validar_extras.R`; os resultados estão em `validacao/auditoria_extras.txt`.

## Limitações que permanecem

- A variância dos erros não é constante. Os intervalos e testes exibidos não receberam correção para esse problema.
- A população de 2022 aproxima a exposição do período 2021–2023; não são utilizadas populações anuais observadas.
- O Gini aproxima a desigualdade por classes de renda e por um universo etário restrito.
- A classe aberta foi calibrada ao Brasil. A coincidência nacional não é uma validação independente.
- A comparação agregada com UFs usa universos diferentes e não valida o Gini exato municipal.
- O SIM pode conter sub-registro ou classificação indeterminada. A intenção indeterminada não comprova homicídio oculto.
- A independência espacial não foi verificada.
- A análise descreve associações entre municípios; não demonstra causa nem risco individual.

A revisão repetiu Box-Cox para a especificação final; o apêndice C mostra o diagnóstico atualizado.
O log permanece uma escolha interpretável, sem ser a potência ótima apontada pelo diagnóstico.
Estudar pesos permanece uma possibilidade de aprofundamento.
Essas escolhas exigem nova avaliação do ajuste e podem mudar as estimativas.
Não foram tratadas como decisões já tomadas nem como obrigação para aumentar a apresentação.

## Matriz das orientações docentes

| Exigência | Onde foi atendida |
|---|---|
| Contextualização e pergunta | Slides 1–2 |
| Base e variáveis | Slides 3–4 |
| Métodos e finalidade | Slides 5–6, apêndices técnicos |
| Ajuste do modelo | Slides 7–9: observado versus ajustado e diagnósticos |
| Interpretação e discussão | Slides 10–14 |
| Limitações e trabalhos futuros | Slides 4, 13 e 14 |
| Gráficos interpretados, além dos testes | Slides 7–12; apêndices H e I (páginas 22–23) |
| Somente a história do modelo final | Corpo da apresentação; comparações auxiliares nos apêndices |
| Diagnóstico antes de VIF | Slides 8–9 antes da crítica e da leitura detalhada dos coeficientes |
| Gini em vez da razão média/mediana | Variável calculada, com limitações explícitas |
| Região e recorte populacional | Região mantida; 30 mil habitantes; 1.133 municípios |
| Sem teste artificial de vizinhos | Ausência do teste e limitação declarada |
| Comparação com e sem renda | Apêndice D |
| Tempo de até 15 minutos | Roteiro de 13 minutos e dois minutos de reserva; ensaio humano pendente |

## Pendências do projeto completo

| Pendência | Situação |
|---|---|
| Ensaio cronometrado | Cada pessoa precisa ensaiar sua fala e suas transições |
| Artigo `.tex` e `.pdf` | Adiado por instrução do usuário; limite de 15 páginas incluindo referências |
| `.qmd` final organizado e comentado | Ainda falta integrar a análise final nesse formato |
| Relatório exploratório antigo | Usa recorte e hipóteses diferentes; não deve ser confundido com o artigo ou código final |
| ZIP único da entrega completa | Depende do artigo e do `.qmd`; a pasta do grupo não é esse ZIP acadêmico |
| Responsável pelo envio | Identificar quem enviará o arquivo e incluir os nomes de todos na mensagem da atividade |
| Merge do PR | Não executado; depende de ordem explícita |

As decisões da apresentação estão fechadas.
A discussão futura sobre correção da variância deve ocorrer antes de tratar uma nova análise como versão final do artigo.
