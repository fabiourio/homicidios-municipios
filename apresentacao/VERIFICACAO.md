# Verificação da apresentação final

Data: 17/11/2026. Base: `1893e89` (`main`). Branch: `apresentacao-final-15-minutos`.

## Configuração aprovada na revisão da narrativa

- 14 páginas principais e nove apêndices, de A a I.
- Meta de 23 páginas no PDF, no PowerPoint e no HTML.
- Cinco briefings, com as mesmas pessoas e ordem da apresentação parcial; conteúdos condensados e redistribuídos.
- Roteiro de 780 segundos: 75/90/120/180/315 segundos por pessoa.
- Abertura de 165 segundos; dois minutos de reserva até o limite informado.
- Marcos finais: 1min15, 2min45, 4min45, 7min45 e 13min00.
- Último slide: 60 segundos. Rodapé apenas com numeração; fontes retiradas da projeção; legendas técnicas preservadas.
- As falas são metas de ensaio. A duração de uma apresentação real não foi medida.

O verificador confirmou os critérios acima na geração final de 17/11/2026.
As evidências nas seções seguintes registram as versões anteriores à [revisão da narrativa](../decisoes/revisao-semantica-apresentacao.md).
A evidência da geração atual está no encerramento deste registro.

## Reprodução e integridade — registro anterior

1. O código original da análise foi extraído de `1893e89` para uma pasta temporária.
2. Os dois scripts originais foram executados sobre os dados reais do repositório.
3. O gerador atual executou novamente os dois scripts antes de produzir números e figuras.
4. Os 16 arquivos numéricos CSV/TXT permaneceram idênticos aos produzidos pela base, por comparação de hashes.
5. `git diff --exit-code 1893e89 -- dados entrega/dados entrega/resultados` confirmou ausência de alterações nesses arquivos.
6. A única alteração no código da análise é a descrição da decisão região/estado em um comentário existente.
7. Os gráficos novos usam os mesmos municípios e o mesmo ajuste estatístico.

Comandos executados:

```sh
Rscript gerar_numeros.R
tectonic -X compile --keep-logs apresentacao_final.tex
Rscript exportar_pptx_html.R
Rscript gerar_briefings.R
Rscript verificar_materiais.R
```

As pastas de execução estão documentadas no [LEIA-ME](LEIA-ME.md).

## Verificação dos arquivos entregues — registro anterior

O script `verificar_materiais.R` confere os materiais finais, não apenas seus arquivos-fonte:

- Quantidade de páginas do PDF e de slides do PowerPoint.
- Correspondência das notas reais do PowerPoint e do HTML com as falas resolvidas.
- Ausência de marcadores numéricos sem substituição.
- Igualdade do PDF exportado com o PDF compilado.
- Numeração contínua das páginas da versão então verificada.
- Presença das cinco pessoas e seus tempos aprovados.
- Identificação da fala completa de cada slide nos briefings.
- Contexto, perguntas, transições e marcos de tempo nos briefings.
- Taxa de palavras por minuto dentro dos tempos planejados.

O detalhamento fica em [tempos_verificados.csv](tempos_verificados.csv).

Casos de falha testados em cópias temporárias:

| Caso | Resultado esperado | Resultado obtido |
|---|---|---|
| Alterar uma fala sem atualizar o PowerPoint | Rejeitar a divergência | Rejeitado, saída 1 |
| Aumentar o roteiro para 781 segundos | Rejeitar o tempo diferente do aprovado | Rejeitado, saída 1 |

## Revisão científica

- A medida inclui X85–Y09 e Y35–Y36. A definição não equivale estritamente ao indicador ODS 16.1.1.
- A comparação direta com a média mundial foi retirada.
- O R² ajustado é apresentado na escala de ln(taxa).
- A transformação inversa do ajuste é descrita como taxa típica, sem chamar de média aritmética esperada.
- A variação do efeito do Gini aparece com a renda; não há afirmação de efeito nulo geral nos municípios pobres.
- O percentil 90 é tratado como um ponto da distribuição, não como todo o grupo dos 10% mais ricos.
- A variância não constante limita a leitura dos intervalos e testes clássicos.
- Shapiro-Wilk não rejeita normalidade; não foi tratado como prova.
- O sinal da desocupação não foi atribuído com certeza à multicolinearidade.
- Box-Cox não foi apresentado como seleção da potência zero.
- A vizinhança permanece uma limitação sem teste espacial novo.

Fonte para a definição oficial: [metadados ONU/UNODC](https://unstats.un.org/sdgs/metadata/files/Metadata-16-01-01.pdf).

## Revisão visual — registro anterior

- O agente principal inspecionou montagens dos slides 1–14.
- Uma revisão independente inspecionou os slides 8–23, as cinco capas e uma página de fala.
- A revisão não identificou cortes, sobreposições ou eixos ilegíveis.
- Os logs finais do deck e dos briefings não contêm `Overfull` nem `Missing character`.
- Os rótulos dos eixos de Douglas foram corrigidos para ln(taxa).
- Os rótulos longos dos briefings foram colocados em linhas próprias para eliminar transbordamento.

O PDF do guia de decisões resume `../decisoes/discussao-final-17-11-2026.md`.
O HTML do guia também preserva as propostas históricas, identificadas como histórico.
O guia foi recompilado com Pandoc e Tectonic, sem transbordamentos no PDF final.

## Registro dos agentes

| Agente | Escopo | Resultado |
|---|---|---|
| `decisoes_documentacao` | Documentação e decisões | Concluído, revisão pelo agente principal |
| `auditoria_estatistica` | Definições e interpretação científica | Correções incorporadas; revisão final sem bloqueios |
| `briefings_falas` | Fontes dos cinco briefings e gerador de tempos | Concluído, cinco PDFs compilados e conferidos |
| `revisao_visual_final` | Artefatos renderizados | Sem defeitos encontrados nas páginas inspecionadas |
| `revisao_geradores` | Geradores em R e correspondência das exportações | Sem achados; verificador executado com sucesso |

`subagent_tokens` não foi disponibilizado pelas ferramentas. Não há medição exata por agente para afirmar o percentual da janela usado.
Nenhum agente fez merge ou enviou mensagens ao grupo.

## Limites e continuação

- Não houve ensaio humano cronometrado.
- O PowerPoint preserva o visual como imagens; a fonte editável é o Beamer.
- A revisão não acrescentou outro modelo nem corrigiu a variância dos erros.
- O artigo final ficou fora desta etapa por instrução do usuário.
- O `.qmd` final foi concluído na conferência posterior. O ZIP completo depende do artigo.

## Repositório e entrega para revisão

- [PR 12](https://github.com/fabiourio/homicidios-municipios/pull/12) aberto sobre `main`.
- Branch publicada: `apresentacao-final-15-minutos`.
- O GitHub informou ausência de conflitos de merge.
- Na consulta final, não havia revisão remota nem verificações automáticas registradas. As revisões independentes desta sessão estão descritas acima.
- Nenhum merge foi executado. A branch permanece disponível para revisão do grupo.

Somente após ordem explícita para integrar:

```sh
gh pr merge 12 --repo fabiourio/homicidios-municipios --merge
```

## Revisão complementar com a apostila — registro anterior

A [revisão do projeto completo](../decisoes/revisao-projeto-apostila.md) consultou diretamente os capítulos oficiais.
Ela acrescentou os apêndices J e K, com resíduos contra cada explicativa, conforme a seção 4.4.
O deck passou a 25 páginas: as mesmas 14 principais, com 11 apêndices. O tempo planejado continua em 13 minutos.
A definição do Gini por pessoas de 14 anos ou mais ficou explícita nos slides e nos briefings.
Os universos diferentes na comparação com o Gini oficial ficaram registrados como limitação.
A revisão das fontes locais comparou 44.560 células sem divergências; a execução está em `../validacao/saida/07_extras_fontes.txt`.
Os gráficos novos foram revisados. Um problema de legenda e um excesso vertical foram corrigidos antes da exportação final.
O verificador agora também rejeita os avisos de corte de conteúdo presentes nos logs de compilação.
A pasta para o grupo é gerada por `preparar_pasta_grupo.R`, com manifesto de hashes e conferência das cópias.
Essa pasta não substitui o ZIP completo da entrega acadêmica.

Agentes adicionais: `revisao_apostila_metodos`, `revisao_dados_fontes` e `revisao_apoio_apostila`.
A ferramenta não forneceu contagens individuais de `subagent_tokens`.

## Revisão da narrativa — 17/11/2026

O usuário pediu retirar os apêndices de referências e o rodapé repetido, além de verificar hipóteses e tempo.
A [especificação da revisão](../decisoes/revisao-semantica-apresentacao.md) preserva dados, modelo e ordem dos cinco apresentadores.

- A sequência passa a contexto (1–2), dados (3–4), métodos (5–6), ajuste (7–9) e discussão (10–14).
- O slide 7 mostra taxas observadas e ajustadas; os dois gráficos exploratórios permanecem disponíveis no repositório.
- Os antigos diagnósticos J–K passam a H–I, páginas 22–23, após retirar os apêndices de referências.
- As hipóteses permanecem expectativas iniciais; a abertura apresenta problema e pergunta.
- H2 trata de exclusão escolar; H3 trata de migração recente, não imigração internacional.
- A migração permanece no modelo, sem evidência clara de associação (p clássico = 0,143).
- A retirada da medida problemática de intenção indeterminada mudou o apoio a H3; o registro explica essa comparação.

Verificações desta revisão:

- [x] Regenerar PDF, PowerPoint, HTML, notas e cinco briefings.
- [x] Conferir 23 páginas, apêndices A–I, numeração e ausência de fontes visíveis.
- [x] Conferir tempos, marcos, correspondência das falas e função de cada slide.
- [x] Inspecionar os gráficos e as páginas alteradas.
- [x] Executar o verificador atualizado e conferir a integridade dos dados e do modelo.
- [x] Regenerar o guia PDF e a pasta do grupo; conferir as cópias.

O verificador passou com 23 páginas, 14 slides principais e cinco briefings.
As notas do PowerPoint e HTML são idênticas. Os logs não apresentam cortes de conteúdo.
A conferência visual cobriu o corpo e os apêndices; Box-Cox, metodologia e conclusão foram inspecionados após os últimos ajustes.


## Auditoria computacional final

`validacao/auditar_modelo.R` foi executado e registrou 365 medidas e comparações.
A reconstrução independente preservou coeficientes; efeitos e intervalos tiveram diferenças inferiores a 1e-10.
O PRESS foi conferido por 1.133 reajustes diretos, sem caracterizá-lo como validação externa.
Os cenários incluíram Nova Lima, Campos, cortes populacionais e estados.
Região permanece no modelo principal, conforme confirmação reiterada do usuário.
Box-Cox foi repetido com a especificação final e atualizou o apêndice C; o log segue fora do intervalo.
As limitações de variância desigual e independência espacial não verificada permanecem explícitas.
A [revisão do modelo](../validacao/REVISAO_MODELO_FINAL.md) distingue resultado reproduzido de hipótese confirmada.

Tempos e volume das falas, após substituir as macros:

| Pessoa | Tempo | Palavras | Marco final |
|---|---:|---:|---:|
| Kauan | 75s | 112 | 1min15 |
| Fabio | 90s | 186 | 2min45 |
| Douglas | 120s | 178 | 4min45 |
| Luiz Felipe | 180s | 270 | 7min45 |
| Willian | 315s | 512 | 13min00 |

O roteiro inclui interpretação dos gráficos e pausas; as falas não devem preencher o tempo com leitura adicional.
O ensaio humano continua pendente. Os cinco briefings apresentam o mesmo tempo, início e fim conferidos automaticamente.
A conferência inicial preservou os resultados originais. Na revisão posterior, rótulos da taxa típica foram corrigidos.
As bases, os coeficientes e as 15 tabelas CSV permanecem numericamente iguais ao ajuste anterior.

Agentes desta revisão: `auditoria_modelo_final`, `coerencia_conclusoes`, `documentacao_narrativa`,
`briefings_narrativa` e `revisao_semantica_visual`.
Os trabalhos foram delimitados por arquivos; a revisão visual não alterou as fontes.
A ferramenta não disponibilizou `subagent_tokens`; a contagem individual não pôde ser medida.

A pasta `Desktop/GED-16-apresentacao-final` foi atualizada após conferir o manifesto anterior.
O novo manifesto confere 18 arquivos; a comparação confirmou cópias idênticas à preparação temporária.
Slides, cinco briefings e relatório da auditoria acompanham a mensagem pronta para o grupo.


## Retirada das fontes visíveis — correção solicitada pelo usuário

As linhas de fonte e as citações foram retiradas das 23 páginas.
As legendas técnicas dos gráficos permanecem, incluindo eixos, intervalos e limitações.
SIM/DATASUS, IBGE e INEP aparecem no slide de dados, conforme o roteiro docente.
O registro `referencias-dos-slides.md` preserva as informações retiradas da projeção.
PDF, PowerPoint, HTML e cinco briefings foram regenerados.
O verificador passou e agora rejeita linhas “Fonte:” ou “Fontes:” no texto dos slides.
A revisão visual conferiu o slide de dados e um gráfico com legenda técnica.
A pasta do Desktop foi atualizada; os 18 arquivos e o manifesto coincidem com a preparação verificada.


## Conferência de todos os pedidos da conversa

A matriz `../decisoes/conferencia-pedidos-17-11-2026.md` registra os pedidos, as evidências e 11 divergências corrigidas.
O `.qmd` havia sido adiado sem instrução; o usuário adiou somente o artigo. Essa pendência foi corrigida.
`entrega/analise_final.qmd` executou em cópia isolada; 15 tabelas coincidiram com tolerância de 1e-12.
`validacao/saida/10_conferencia_caderno.txt` registra a comparação dos códigos embutidos e das tabelas.
O ajuste conserva as bases, os coeficientes e região. Rótulos da taxa típica e a execução local de Box-Cox foram corrigidos.
A transcrição e o ZIP recebido foram confrontados com os originais do Desktop e Downloads.
As 23 páginas foram inspecionadas; dois painéis que entravam no subtítulo foram movidos para o corpo.
As hipóteses ficaram explícitas nos resultados. O município foi explicado como unidade e região como explicativa.
O verificador passou após regenerar slides e briefings. A capa preserva “Novembro de 2026”.

O pacote final contém 30 arquivos mais manifesto. A pasta do Desktop foi atualizada e seus hashes conferem.
Os documentos de apoio adaptam os links para o pacote; os outros arquivos preservam o conteúdo das fontes.
O caderno e suas bases acompanham a apresentação em `04_codigo`.
Não houve nova delegação nesta conferência integral, envio externo ou merge.
