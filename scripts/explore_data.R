library(readr)
library(readxl)
library(dplyr)#library(ggplot2)
library(tidyverse)

# CIENCIAS DE LA COMPUTACION
# ARQUITECTURA
# FISICA
# MATEMATICAS

rm(list= ls())
carrera <- "ARQUITECTURA"

df_raw <- read.csv(paste0("./data/raw/",carrera,"/2021.csv"),fileEncoding = "UTF-8", check.names = FALSE, blank.lines.skip = TRUE)
colnames(df_raw)

# Histograma básico
df_raw$Aciertos<-as.numeric(df_raw$Aciertos)
hist(df_raw$Aciertos)

# Histograma más profesional con ggplot
ggplot(df_raw, aes(x = Aciertos)) + 
  geom_histogram(binwidth = 2, fill = "steelblue", color = "white") +
  labs(title = "Histograma con ggplot2", 
       x = "MPG", 
       y = "Frecuencia")   


unique(df_raw$Acreditado)

df_raw$Acreditado <- dplyr::case_when(
  as.character(df_raw$Acreditado) == "N" ~ "No",
  as.character(df_raw$Acreditado) == "S" ~ "Sí",
  as.character(df_raw$Acreditado) == "" ~ "NP",
  TRUE ~ as.character(df_raw$Acreditado)
)

df_raw <- df_raw %>%
  mutate(Acreditado = case_when(
    Acreditado == "N" ~ "No",
    Acreditado == "S" ~ "Sí",
    Acreditado == "" ~ "NP",
    TRUE ~ Acreditado
  ))


df_raw$Acreditado <- as.factor(df_raw$Acreditado)

tabla<-as.data.frame(table(df_raw$Acreditado))
print(unique(tabla$Freq))


ggplot(tabla,aes(x=reorder(Var1,Freq),y = Freq))+
  geom_bar(stat = "identity",fill ="steelblue")+
  labs(title = "Resultados aspirantes", 
       x = "Acreditado", 
       y = "Total") 

