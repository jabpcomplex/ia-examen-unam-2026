library(rvest)
library(xml2)
library(dplyr)
library(purrr)
library(readr)

#--------------------------------------------
# URL de prueba
#--------------------------------------------

url <- "https://www.dgae.unam.mx/Licenciatura2026/resultados/1/10100035.html"

#--------------------------------------------
# Leer página
#--------------------------------------------

pagina <- read_html(url)

#--------------------------------------------
# Localizar el tbody
#--------------------------------------------

tbody <- pagina %>%
  html_element("tbody")

#--------------------------------------------
# Extraer filas
#--------------------------------------------

filas <- tbody %>%
  html_elements("tr")

#--------------------------------------------
# Extraer columnas
#--------------------------------------------

datos <- map_dfr(filas, function(fila){
  
  columnas <- fila %>%
    html_elements("td") %>%
    html_text(trim = TRUE)
  
  # Completar si alguna fila tiene menos columnas
  length(columnas) <- max(length(columnas),4)
  
  tibble(
    `Número de comprobante` = columnas[1],
    Aciertos                = columnas[2],
    Acreditado              = columnas[3],
    Detalles                = columnas[4]
  )
  
})

#--------------------------------------------
# Mostrar resultado
#--------------------------------------------

print(datos)

glimpse(datos)

head(datos,20)

#--------------------------------------------
# Guardar CSV (opcional)
#--------------------------------------------

write_csv(datos,"resultados_prueba.csv")


#ERRORES

url <- "https://www.dgae.unam.mx/Licenciatura2026/resultados/1/10100035.html"

browseURL(url)
###########3
library(xml2)

url <- "https://www.dgae.unam.mx/Licenciatura2026/resultados/1/10100035.html"

tryCatch(
  {
    pagina <- read_html(url)
  },
  error = function(e){
    print(e)
  })

############3

library(httr2)

resp <- request(url) |>
  req_perform()

resp_status(resp)


##333333

library(httr2)
library(rvest)

resp <- request(url) |>
  req_perform()

pagina <- resp |>
  resp_body_html()


############


library(httr2)
library(rvest)

url <- "https://www.dgae.unam.mx/Licenciatura2026/resultados/1/10100035.html"

resp <- request(url) |>
  req_user_agent(
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36"
  ) |>
  req_headers(
    Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    `Accept-Language` = "es-MX,es;q=0.9",
    Connection = "keep-alive",
    Referer = "https://www.dgae.unam.mx/"
  ) |>
  req_perform()

resp_status(resp)


#####################

library(curl)

h <- new_handle()

handle_setheaders(
  h,
  "User-Agent"="Mozilla/5.0",
  "Accept"="text/html"
)

curl_fetch_memory(url, handle=h)




###########

# Siguiente diagnóstico
# 
# Quiero saber qué devuelve realmente el servidor cuando rechaza la petición.
# 
# Ejecuta:
  
  library(curl)

url <- "https://www.dgae.unam.mx/Licenciatura2026/resultados/1/10100035.html"

h <- new_handle()

handle_setheaders(
  h,
  "User-Agent" = "Mozilla/5.0"
)

res <- curl_fetch_memory(url, handle = h)

cat(rawToChar(res$content))
