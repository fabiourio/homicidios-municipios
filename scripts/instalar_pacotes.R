# Instala os pacotes de R usados nos scripts 00-03
pkgs <- c("jsonlite", "httr", "readxl", "ggplot2", "dplyr", "tidyr", "GGally", "sf", "MASS", "car", "lmtest")
novos <- setdiff(pkgs, rownames(installed.packages()))
if (length(novos)) install.packages(novos)
