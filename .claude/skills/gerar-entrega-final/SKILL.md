---
name: gerar-entrega-final
description: Gera e confere o .zip da entrega final do trabalho de homicídios de GED-16 (slides, caderno .qmd com os dados e artigo em .tex e .pdf), testando o zip numa pasta vazia. Use sempre que alguém mudar o artigo, o caderno, os dados ou os slides e precisar do .zip atualizado — "gera a entrega", "gera o zip", "atualiza o zip", "preparar a entrega final".
---

# Gerar a entrega final

O enunciado pede um único .zip com: os slides da apresentação; os códigos em R, organizados e comentados, em .qmd; as bases de dados usadas; e o artigo final (no máximo 15 páginas, no modelo do Overleaf) em .tex e .pdf.

Um comando monta e confere tudo. Nenhum número do artigo é digitado à mão: o caderno gera `numeros.tex`, as tabelas e as figuras, e o artigo usa cópias delas.

## Pré-requisitos

- R com os pacotes do projeto: rode uma vez `Rscript scripts/instalar_pacotes.R` (instala os do caderno, `pdftools`, `qpdf` e os das exportações dos slides).
- `quarto` e `tectonic` no PATH.

## Comando

Na raiz do repositório:

```bash
Rscript scripts/06_gerar_entrega.R            # zip em entrega_zip/
Rscript scripts/06_gerar_entrega.R ~/Desktop  # zip em outra pasta
Rscript scripts/06_gerar_entrega.R --slides   # se o .tex dos slides mudou
Rscript scripts/06_gerar_entrega.R --base     # se os dados brutos mudaram
```

No macOS, se `Rscript` não estiver no PATH: `/Library/Frameworks/R.framework/Resources/bin/Rscript`.

## O que o script faz

1. (`--base`) Refaz `entrega_final/dados/` com `scripts/05_base_entrega_final.R`.
2. Renderiza `entrega_final/analise_final.qmd`. Os `stopifnot` do caderno conferem as frases do artigo que dependem de números.
3. Copia para `artigo/` o `numeros.tex` e só as tabelas e figuras que o `artigo.tex` usa. Tabelas e figuras que o artigo não usa são apagadas de `artigo/tabelas/` e `artigo/figuras/`.
4. Compila o artigo e confere: sem referência indefinida, no máximo 15 páginas, resumo e abstract com no máximo 150 palavras e na página 1. O `artigo.pdf` é recompilado a cada execução e muda em bytes mesmo sem mudança no texto: se nada mudou de verdade, descarte com `git checkout -- artigo/artigo.pdf`.
5. (`--slides`) Recompila os slides e as exportações.
6. Monta o zip com `scripts/04_montar_zip_entrega.R` (slides 1 a 15, caderno com os dados, artigo).
7. Descompacta o zip numa pasta vazia, compila o artigo, roda o caderno e compara byte a byte os números, as tabelas e as figuras.

## Quando falhar

| Mensagem | O que fazer |
|---|---|
| Um `stopifnot` do caderno parou | O resultado mudou e uma frase do artigo deixou de valer. Corrija a frase em `artigo/artigo.tex` e a conferência no `.qmd` |
| "O caderno não gerou: ..." | O artigo usa uma tabela ou figura que o caderno não cria. Gere no caderno ou tire do artigo |
| "... páginas; o limite é 15" | Encurte o texto ou reduza figuras. Não mude margens nem o `sbpo-template.sty` |
| "O abstract passou da página 1" ou "mais de 150 palavras" | Encurte o resumo e o abstract |
| "referência ou citação indefinida" | Confira `\ref`, `\label` e as chaves em `artigo/referencias.bib` |
| "O caderno do zip não reproduz" | Rode o script de novo. Se persistir, há algo fora do zip de que o caderno depende |
| "O artigo compilado do zip difere do artigo.pdf" | Falta no zip algum arquivo que o artigo usa (tabela, figura ou .bib). Confira o `scripts/04_montar_zip_entrega.R` |

## Depois de gerar

- Confira o resumo que o script imprime (páginas e palavras).
- Leia o PDF do artigo antes de enviar.
- O zip é para enviar na atividade. Não faça commit da pasta `entrega_zip/` (ela está no `.gitignore`).
