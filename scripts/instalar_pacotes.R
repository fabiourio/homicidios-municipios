# Instala os pacotes de R usados nos scripts 02–04
pkgs <- c("ggplot2", "dplyr", "tidyr", "sf", "spdep", "GGally", "MASS", "car", "lmtest", "leaps", "systemfonts")
novos <- setdiff(pkgs, rownames(installed.packages()))
if (length(novos)) install.packages(novos)
