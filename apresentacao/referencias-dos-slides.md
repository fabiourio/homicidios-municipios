# Referências e notas retiradas da projeção

O usuário pediu retirar as fontes visíveis dos slides em 17/11/2026.
Este registro preserva as informações anteriores. As legendas necessárias à leitura dos gráficos continuam na projeção.
As bases SIM/DATASUS, IBGE e INEP aparecem somente no slide de dados.

A bibliografia do projeto permanece em `relatorio/referencias.bib` e na documentação das decisões.

- **Slide 2:** SIM/DATASUS; IBGE. Média anual de 2021--2023, conforme a definição apresentada no slide seguinte.
- **Slide 3:** SIM/DATASUS; IBGE; INEP. Medida relacionada ao ODS 16; a definição difere do indicador oficial 16.1.1.
- **Slide 4:** Elaboração própria. Cidades menores têm taxas mais instáveis; o recorte não elimina todo problema de registro.
- **Slide 5:** Elaboração própria. Apostila GED-16, caps. 4, 5 e 7. Transformação e comparações auxiliares nos apêndices.
- **Slide 6:** Elaboração própria. Apostila GED-16, caps. 4 e 6. Sem teste baseado em uma ordem artificial de vizinhos.
- **Slide 7:** Modelo final, mesmos dados usados no ajuste. Diagonal: igualdade entre observado e ajustado; não é validação externa.
- **Slide 8:** Modelo final. Linha tracejada: erro zero. Breusch-Pagan: $p$ <0,001. Cada ponto representa um município.
- **Slide 9:** Modelo final. Quantis comparam a distribuição dos resíduos com uma normal. Normalidade não é comprovada pelo teste.
- **Slide 10:** Elaboração própria. p.p. = pontos percentuais. Pontos: estimativas; barras: IC 95% clássico, sem correção de variância. Associação, não causa.
- **Slide 11:** Elaboração própria. Faixa: IC 95% clássico, sem correção de variância. Pontos vermelhos: percentis 10, 50 e 90 da renda.
- **Slide 12:** Elaboração própria. Curvas restritas à renda observada em cada região. Faixas: IC 95% clássico. Não representam média aritmética da taxa.
- **Slide 13:** Diagnóstico do modelo e validação dos dados. VIF máximo 7,6; esse número não substitui a análise dos resíduos.
- **Slide 14:** Fajnzylber et al. (2002); Lochner e Moretti (2004); Wanzinack et al. (2022); Barros et al. (2020). Resultados são associações.
- **Slide 15:** Elaboração própria. Resposta ln(taxa); erros-padrão e testes clássicos, sem correção de variância.
- **Slide 16:** Elaboração própria. Testes clássicos; interpretar com cautela pela variância não constante.
- **Slide 17:** Elaboração própria. Box-Cox com os mesmos termos do modelo final. Não selecionou log como potência ótima.
- **Slide 18:** Elaboração própria. Indicadoras de região omitidas; ao retirar renda, sai a interação. Inferência clássica.
- **Slide 19:** Elaboração própria. Decisão do grupo em 17/11/2026. Comparação preservada para perguntas.
- **Slide 20:** Elaboração própria. $F$ parcial de cada variável somada ao modelo final. Inferência clássica.
- **Slide 21:** Apostila GED-16 e registro das escolhas do grupo. Nenhum novo modelo foi introduzido nesta revisão.
- **Slide 22:** Modelo final, mesmos municípios. Apostila GED-16, seção 4.4: diagnóstico versus cada explicativa na regressão múltipla.
- **Slide 23:** Modelo final. Região entra como categoria; linhas centrais das caixas são medianas. Apoio à leitura dos slides 8 e 9.


## Contextualização revista após o novo comentário do usuário

O slide 2 recupera a comparação internacional para dimensionar o problema, sem linhas de fonte na projeção.
Brasil: 21,3 e mundo: 5,8 homicídios intencionais por cem mil habitantes em 2021; razão aproximada de 3,7.
Dados conferidos nas figuras 5 e 6 do relatório UNODC 2023 e nas publicações oficiais indicadas na análise crítica.
A razão não usa a taxa de 22,7 da base, que cobre 2021–2023 e inclui intervenções legais.
A comparação e a média anual de 46.105 mortes da base são informações distintas, identificadas na fala.
A [análise crítica por slide](../decisoes/analise-critica-slide-a-slide.md) registra os motivos e as fontes.
