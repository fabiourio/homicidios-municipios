# Instala os pacotes de R usados nos scripts do projeto (dados, análise, validação e apresentação)
pkgs <- c("jsonlite", "httr", "readxl", "ggplot2", "dplyr", "tidyr", "GGally", "sf", "MASS", "car", "lmtest",
          "pdftools", "officer", "base64enc")
novos <- setdiff(pkgs, rownames(installed.packages()))
if (length(novos)) install.packages(novos)
