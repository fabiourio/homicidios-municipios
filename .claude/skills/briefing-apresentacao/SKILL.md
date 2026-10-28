---
name: briefing-apresentacao
description: Gera os briefings em PDF, um por apresentador, do trabalho de homicídios de GED-16 (contexto do projeto, decisões e porquês, os slides de cada pessoa com a fala, perguntas prováveis e transições). Use sempre que mudar algo nos slides, no modelo, nos dados, na divisão das falas, ou ao preparar uma nova apresentação — "gera os briefings", "atualiza o briefing", "briefing para a apresentação final".
---

# Briefing por apresentador

Os briefings devem bater com o código e com os slides. Nenhum número é digitado à mão: todos vêm de `apresentacao/latex/numeros.tex`, gerado a partir do código da entrega.

## Arquivos

| Arquivo | Papel |
|---|---|
| `apresentacao/notas.json` | Uma nota por página do deck, começando com `[Nome]` de quem apresenta. Números como `{Macro}` (ex.: `{RdoisA}`), nunca digitados. É a fonte da divisão das falas |
| `apresentacao/latex/<deck>.tex` | Slides (títulos lidos na ordem dos frames; capa = página 1) |
| `apresentacao/latex/gerar_numeros.R` | Roda o código da entrega e gera `numeros.tex` e `tabelas/`. Também confere as frases fixas dos slides e dos briefings |
| `apresentacao/briefings/comum.tex` | Parte igual para todos: o projeto em um minuto, decisões e porquês, resultados, pendências, glossário |
| `apresentacao/briefings/parte_<nome>.tex` | Parte de cada pessoa: mensagem principal, o que enfatizar, perguntas prováveis com resposta, transição |
| `apresentacao/briefings/gerar_briefings.R` | Monta e compila `briefing_<nome>.pdf` (slides da pessoa ao lado da fala + parte + comum) |
| `apresentacao/exportar_pptx_html.R` | Exporta o deck para `.pptx` e `.html` com as notas |

`<nome>` é o nome em minúsculas, sem acento, com `_` no lugar do espaço (ex.: `luiz_felipe`).

## Passo a passo

1. **Números:** `cd apresentacao/latex && Rscript gerar_numeros.R`. Se parar com "O resultado não sustenta mais a frase…", a frase citada mudou de verdade: corrija o texto do slide, a nota e o briefing, e ajuste a conferência correspondente.
2. **Slides:** `tectonic -X compile <deck>.tex` (o briefing usa as imagens do PDF).
3. **Atualizar o texto**, lendo antes o que mudou (slides, `notas.json`, `CLAUDE.md`, `entrega/LEIA-ME.md`, `validacao/RELATORIO.md`, memória do projeto):
   - `notas.json`: uma nota por página, na ordem; `[Nome]` em cada uma, exceto o apêndice. Confira se o número de notas é igual ao de páginas.
   - `comum.tex`: decisões novas entram na tabela de decisões com o porquê e o capítulo da apostila. Remova decisões revertidas.
   - `parte_<nome>.tex`: para cada apresentador presente em `notas.json`. Se alguém novo entrar, crie a parte dele; se alguém sair, apague a dele.
4. **Gerar:** `cd apresentacao/briefings && Rscript gerar_briefings.R [<deck>]` (padrão: `apresentacao_parcial`).
5. **Conferir:**
   - nenhum número digitado em `comum.tex`, `parte_*.tex` e `notas.json`: `grep -nE '[0-9]+,[0-9]+' ...` só pode achar macros ou nada;
   - cada PDF abre, com a capa "Você apresenta / Antes de você / Depois de você" certa;
   - renderize pelo menos um briefing (`pdftoppm -r 55`) e olhe as páginas.
6. **Exportar o deck:** se slides ou notas mudaram, `cd apresentacao && Rscript exportar_pptx_html.R [<deck>]` (gera `.pdf`, `.pptx` e `.html` iguais, com as notas).

## Como escrever

- Português simples, frases curtas, como aluno de graduação explicando para o colega; nada de jargão sem explicação (o glossário do `comum.tex` cobre os termos técnicos).
- Toda decisão leva o porquê. Toda técnica precisa estar na apostila de GED (regra do grupo, `CLAUDE.md`).
- Perguntas prováveis: 2 ou 3 por pessoa, as que a professora ou a turma mais provavelmente fariam sobre aquela parte, com resposta de 1 ou 2 frases.
- Número novo no texto: crie a macro em `gerar_numeros.R` (e, se for uma afirmação, uma conferência com `confere()`); nunca digite.
- O briefing não é entregue à professora; é material interno do grupo.
