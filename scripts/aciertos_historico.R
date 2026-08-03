library(tidyverse)
rm(list= ls())
# CIENCIAS DE LA COMPUTACION
# ARQUITECTURA
# FISICA
# MATEMATICAS
# URBANISMO

carrera <- "CIENCIAS DE LA COMPUTACION"

# 1. Definir ruta y obtener lista de archivos
archivos_csv <- list.files(path = paste0("./data/raw/",carrera), pattern = "\\.csv$", full.names = TRUE)

# 2. Leer y concatenar todos los CSVs
# Se asume que el nombre del archivo contiene el año (ej. "2021.csv"). 
# Si no, se puede generar un índice secuencial.
df_combined <- lapply(archivos_csv, function(file) {
  temp_df <- read.csv(file, fileEncoding = "UTF-8", check.names = FALSE, blank.lines.skip = TRUE)
  
  # Extraer el año del nombre del archivo (ajustar regex si el formato es distinto)
  # Esto toma los números encontrados en el nombre del archivo
  anio <- gsub("[^0-9]", "", basename(file)) 
  
  temp_df$Aciertos <- as.numeric(temp_df$Aciertos)
  temp_df$Anio <- anio
  return(temp_df)
}) %>% bind_rows()

# Verificar datos
print(paste("Total de filas cargadas:", nrow(df_combined)))
print(paste("Años encontrados:", paste(unique(df_combined$Anio), collapse = ", ")))


# 3. Gráfica por año con Facet Wrap
# Usamos facet_wrap(~ Anio) para generar un gráfico por año automáticamente
ggplot(df_combined, aes(x = Aciertos)) + 
  # Histograma escalado a densidad (y = ..density..)
  geom_histogram(aes(y = after_stat(density)), 
                 binwidth = 2, 
                 fill = "steelblue", 
                 color = "white", 
                 alpha = 0.6) + 
  # Línea de densidad continua en rojo
  geom_density(color = "red", linewidth = 1.2) + 
  # Facetas para separar por año
  facet_wrap(~ Anio, ncol = 2) + 
  labs(title = "Distribución de Aciertos por Año ",
       subtitle = paste0("UNAM ",carrera),
       x = "Número de Aciertos", 
       y = "Densidad de Probabilidad") +
  theme_minimal()   


