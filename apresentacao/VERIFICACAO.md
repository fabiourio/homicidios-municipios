# Verificação da apresentação final

Data: 17/11/2026. Base: `1893e89` (`main`). Branch: `apresentacao-final-15-minutos`.

## Resultado

- 14 páginas principais e nove apêndices.
- 23 páginas no PDF, no PowerPoint e no HTML.
- Cinco briefings completos, com a mesma divisão da apresentação parcial.
- Roteiro de 780 segundos: 90/90/120/180/300 segundos por pessoa.
- Abertura de 180 segundos; dois minutos de reserva até o limite informado.
- As falas são metas de ensaio. A duração de uma apresentação real não foi medida.

## Reprodução e integridade

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

## Verificação dos arquivos entregues

O script `verificar_materiais.R` confere os materiais finais, não apenas seus arquivos-fonte:

- Quantidade de páginas do PDF e de slides do PowerPoint.
- Correspondência das notas reais do PowerPoint e do HTML com as falas resolvidas.
- Ausência de marcadores numéricos sem substituição.
- Igualdade do PDF exportado com o PDF compilado.
- Numeração contínua das 23 páginas.
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

## Revisão visual

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
- O `.qmd` e o ZIP completo da entrega permanecem na etapa de fechamento do artigo.

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
