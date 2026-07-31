# Instalar paquetes si no los tienes (ejecutar una vez en consola)
# install.packages(c("shiny", "shinydashboard", "plotly", "tidyverse", "scales"))

library(shiny)
library(shinydashboard)
library(plotly)
library(tidyverse)
library(scales)

# --- 1. CONFIGURACIÓN Y CARGA DE DATOS ---

# Definir las carreras disponibles según tu estructura de carpetas
carreras_disp <- c("CIENCIAS DE LA COMPUTACION", "ARQUITECTURA", "FISICA","MATEMATICAS")

# Función para cargar datos de una carrera específica
cargar_datos_carrera <- function(carrera) {
  ruta_carrera <- paste0("./data/raw", carrera)
  
  if (!dir.exists(ruta_carrera)) return(NULL)
  
  archivos <- list.files(path = ruta_carrera, pattern = "\\.csv$", full.names = TRUE)
  
  if (length(archivos) == 0) return(NULL)
  
  df_list <- lapply(archivos, function(file) {
    temp_df <- read.csv(file, fileEncoding = "UTF-8", check.names = FALSE, blank.lines.skip = TRUE)
    
    # Validar que exista la columna Aciertos
    if (!"Aciertos" %in% colnames(temp_df)) return(NULL)
    
    temp_df$Aciertos <- as.numeric(temp_df$Aciertos)
    
    # Extraer año (asumiendo que el nombre del archivo son solo números o contiene el año)
    nombre <- basename(file)
    anio <- gsub("[^0-9]", "", nombre)
    if (nchar(anio) == 4) {
      temp_df$Anio <- anio
    } else {
      temp_df$Anio <- "Desconocido"
    }
    temp_df$Carrera <- carrera
    return(temp_df)
  })
  
  df_final <- bind_rows(df_list)
  # Ordenar años cronológicamente
  #df_final$Anio <- factor(df_final$Anio, levels = sort(unique(df_final$Anio)))
  return(df_final)
}

# Cargar todos los datos al inicio (o hacerlo reactivo si son millones de filas)
# Para este ejemplo, cargamos todo en un entorno global para eficiencia
datos_globales <- lapply(carreras_disp, cargar_datos_carrera) %>% bind_rows()

###### ui ####
# --- 2. INTERFAZ DE USUARIO (UI) ---

ui <- dashboardPage(
  dashboardHeader(title = "Resultados UNAM 2026"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Vista General", tabName = "general", icon = icon("chart-bar")),
      menuItem("Comparativa Histórica", tabName = "comparativa", icon = icon("layers")),
      menuItem("Detalles por Año", tabName = "detalle", icon = icon("search")),
      menuItem("Acreditación", tabName = "acreditacion", icon = icon("check-circle"))
    ),
    br(),
    box(
      title = "Filtros",
      width = 12,
      selectInput("sel_carrera", "Carrera:", choices = carreras_disp, selected = "ARQUITECTURA"),
      uiOutput("ui_anios")
    )
  ),
  dashboardBody(
    tags$head(tags$style(HTML("
      .box { box-shadow: 0 4px 8px rgba(0,0,0,0.1); border-top: 3px solid #3c8dbc; }
    "))),
    tabItems(
      # PESTAÑA 1: VISTA GENERAL
      tabItem(tabName = "general",
              fluidRow(
                valueBoxOutput("vb_total", width = 4),
                valueBoxOutput("vb_media", width = 4),
                valueBoxOutput("vb_max", width = 4)
              ),
              fluidRow(
                box(title = "Distribución de Aciertos (Año Seleccionado)", width = 12, solidHeader = TRUE, status = "primary",
                    plotlyOutput("plot_principal", height = "500px")
                )
              ),
              fluidRow(
                box(title = "Tabla de Datos Reciente", width = 12, DT::dataTableOutput("tabla_resumen"))
              )
      ),
      
      # PESTAÑA 2: COMPARATIVA
      tabItem(tabName = "comparativa",
              fluidRow(
                box(title = "Evolución y Sesgo 2026 vs Años Anteriores", width = 12, solidHeader = TRUE, status = "warning",
                    plotlyOutput("plot_comparativo", height = "600px")
                )
              ),
              fluidRow(
                box(title = "Estadísticas por Año", width = 12, DT::dataTableOutput("tabla_estadisticas"))
              )
      ),
      
      # PESTAÑA 3: ACREDITACIÓN (ACTUALIZADA CON 5 KPIs)
      tabItem(tabName = "acreditacion",
              fluidRow(
                valueBoxOutput("vb_porcentaje", width = 3),
                valueBoxOutput("vb_acreditados", width = 2),
                valueBoxOutput("vb_no_acreditados", width = 2),
                valueBoxOutput("vb_no_presento", width = 2),
                valueBoxOutput("vb_cancelados", width = 2)
              ),
              fluidRow(
                box(title = "Distribución de Resultados", width = 12, solidHeader = TRUE, status = "success",
                    p("Resultados: Sí, No, NP (No Presentó), Cancelado."),
                    plotlyOutput("plot_acreditacion", height = "500px")
                )
              ),
              fluidRow(
                box(title = "Tabla de Frecuencias", width = 12, DT::dataTableOutput("tabla_acreditacion"))
              )
      ),
      
      # PESTAÑA 4: DETALLE POR AÑO
      tabItem(tabName = "detalle",
              fluidRow(
                box(title = "Distribución por Año (Facetas)", width = 12,
                    plotlyOutput("plot_facetas", height = "700px")
                )
              )
      )
    )
  )
)

# --- 3. LÓGICA DEL SERVIDOR (SERVER) ---

server <- function(input, output, session) {
  
  datos_carrera <- reactive({
    req(input$sel_carrera)
    filter(datos_globales, Carrera == input$sel_carrera)
  })
  
  output$ui_anios <- renderUI({
    df <- datos_carrera()
    if (is.null(df) || nrow(df) == 0) return(NULL)
    anios_disp <- sort(unique(df$Anio))
    selectInput("sel_anio", "Año de análisis:", choices = anios_disp, selected = max(anios_disp))
  })
  
  datos_filtrados <- reactive({
    req(input$sel_anio)
    df <- datos_carrera()
    filter(df, Anio == input$sel_anio)
  })
  
  # --- KPIs GENERALES ---
  output$vb_total <- renderValueBox({
    valueBox(nrow(datos_filtrados()), "Aspirantes", icon = icon("users"), color = "blue")
  })
  output$vb_media <- renderValueBox({
    valueBox(round(mean(datos_filtrados()$Aciertos, na.rm = TRUE), 2), "Promedio Aciertos", icon = icon("graduation-cap"), color = "green")
  })
  output$vb_max <- renderValueBox({
    valueBox(max(datos_filtrados()$Aciertos, na.rm = TRUE), "Máximo Aciertos", icon = icon("trophy"), color = "yellow")
  })
  
  # --- GRÁFICO 1: PRINCIPAL ---
  output$plot_principal <- renderPlotly({
    df <- datos_filtrados()
    p <- ggplot(df, aes(x = Aciertos)) +
      geom_histogram(aes(y = after_stat(density)), binwidth = 2, fill = "steelblue", color = "white", alpha = 0.6) +
      geom_density(color = "red", linewidth = 1.2) +
      labs(title = paste("Distribución", input$sel_anio), subtitle = input$sel_carrera, x = "Aciertos", y = "Densidad") +
      theme_minimal()
    ggplotly(p) %>% layout(hovermode = "x unified")
  })
  
  # --- GRÁFICO 2: COMPARATIVA ---
  output$plot_comparativo <- renderPlotly({
    df <- datos_carrera()
    p <- ggplot(df, aes(x = Aciertos, color = Anio, fill = Anio)) +
      geom_density(alpha = 0.3, linewidth = 1.5) +
      labs(title = "Comparativa Histórica", subtitle = "Superposición de densidades", x = "Aciertos", y = "Densidad") +
      theme_minimal() + theme(legend.position = "bottom")
    ggplotly(p) %>% layout(hovermode = "x unified")
  })
  
  # --- LÓGICA DE ACREDITACIÓN ---
  datos_acreditacion <- reactive({
    df <- datos_filtrados()
    req(nrow(df) > 0)
    
    # Limpieza y transformación robusta
    val <- toupper(trimws(as.character(df$Acreditado)))
    
    df$Acreditado <- dplyr::case_when(
      val %in% c("S", "SI", "Y")      ~ "SI",
      val %in% c("N", "NO")           ~ "NO",
      val %in% c("C", "CANCELADO")    ~ "CANCELADO", # Nueva categoría
      val %in% c("", "NA", "N/A", "-")~ "NP",
      TRUE                            ~ "NP" # Cualquier otro valor raro va a NP
    )
    
    # Definir niveles con las 4 categorías
    niveles <- c("SI", "NO", "NP", "CANCELADO")
    df$Acreditado <- factor(df$Acreditado, levels = niveles)
    
    # Crear tabla
    tabla <- as.data.frame(table(df$Acreditado))
    colnames(tabla) <- c("Resultado", "Frecuencia")
    
    # FORZAR que existan las 4 categorías aunque el conteo sea 0
    faltantes <- setdiff(niveles, tabla$Resultado)
    if (length(faltantes) > 0) {
      df_faltantes <- data.frame(Resultado = factor(faltantes, levels = niveles), Frecuencia = 0)
      tabla <- rbind(tabla, df_faltantes)
    }
    
    tabla <- tabla[order(factor(tabla$Resultado, levels = niveles)), ]
    tabla$Resultado <- factor(tabla$Resultado, levels = niveles)
    
    return(tabla)
  })
  
  # KPIs ACREDITACIÓN (4 TARJETAS)
  
  # --- Tasa de acreditación ---
  output$vb_porcentaje <- renderValueBox({
    tabla <- datos_acreditacion()
    total <- sum(tabla$Frecuencia)
    freq_si <- tabla$Frecuencia[tabla$Resultado == "SI"]
    if (length(freq_si) == 0) freq_si <- 0
    pct <- if (total > 0) round((freq_si / total) * 100, 1) else 0
    valueBox(paste0(pct, "%"), "Tasa de Acreditación", icon = icon("percent"), color = "green")
  })
  # --- Conteo de acreditados ---
  output$vb_acreditados <- renderValueBox({
    tabla <- datos_acreditacion()
    val <- tabla$Frecuencia[tabla$Resultado == "SI"]
    if (length(val) == 0) val <- 0
    valueBox(val, "Acreditados", icon = icon("check"), color = "olive")
  })
  # --- Conteo de NO acreditados ---
  output$vb_no_acreditados <- renderValueBox({
    tabla <- datos_acreditacion()
    val <- tabla$Frecuencia[tabla$Resultado == "NO"]
    if (length(val) == 0) val <- 0
    valueBox(val, "No Acreditados", icon = icon("times"), color = "red")
  })
  # --- Conteo de cancelado ---
  output$vb_no_presento <- renderValueBox({
    tabla <- datos_acreditacion()
    val <- tabla$Frecuencia[tabla$Resultado == "NP"]
    if (length(val) == 0) val <- 0
    valueBox(val, "No presento", icon = icon("ban"), color = "orange")
  })
  # --- Conteo de cancelado ---
  output$vb_cancelados <- renderValueBox({
    tabla <- datos_acreditacion()
    val <- tabla$Frecuencia[tabla$Resultado == "CANCELADO"]
    if (length(val) == 0) val <- 0
    valueBox(val, "Cancelados", icon = icon("ban"), color = "purple")
  })
  
  # GRÁFICO ACREDITACIÓN (4 BARRAS)
  output$plot_acreditacion <- renderPlotly({
    tabla <- datos_acreditacion()
    # Colores distintivos para las 4 categorías
    colores <- c("SI" = "#28a745", "NO" = "#dc3545", "NP" = "orange", "CANCELADO" = "purple")
    
    p <- ggplot(tabla, aes(x = Resultado, y = Frecuencia, fill = Resultado)) +
      geom_bar(stat = "identity", width = 0.6) +
      scale_fill_manual(values = colores) +
      scale_x_discrete(labels = c("SI" = "Sí", "NO" = "No", "NP" = "No Presentó", "CANCELADO" = "Cancelado")) +
      geom_text(aes(label = Frecuencia), vjust = -0.5, size = 6, fontface = "bold") +
      labs(title = paste("Resultados -", input$sel_anio), subtitle = input$sel_carrera, x = "¿Pasaron el exámen?", y = "Aspirantes") +
      theme_minimal() + theme(legend.position = "none", axis.text.x = element_text(size = 12, face = "bold"))
    
    ggplotly(p) %>% config(displayModeBar = FALSE)
  })
  
  output$tabla_acreditacion <- DT::renderDataTable({
    datos_acreditacion()
  }, options = list(pageLength = 5, searching = FALSE, paging = FALSE, language = list(url = '//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json')))
  
  # --- GRÁFICO 3: FACETAS ---
  output$plot_facetas <- renderPlotly({
    df <- datos_carrera()
    p <- ggplot(df, aes(x = Aciertos)) +
      geom_histogram(aes(y = after_stat(density)), binwidth = 2, fill = "steelblue", color = "white", alpha = 0.6) +
      geom_density(color = "red", linewidth = 1) +
      facet_wrap(~ Anio, ncol = 3) +
      labs(title = "Distribución por Año", subtitle = input$sel_carrera, x = "Aciertos", y = "Densidad") +
      theme_minimal() + theme(strip.text = element_text(size = 12, face = "bold"))
    ggplotly(p)
  })
  
  # --- TABLAS ---
  output$tabla_resumen <- DT::renderDataTable({
    datos_filtrados() %>% select(Aciertos, Acreditado, Anio, Carrera) %>% head(100)
  }, options = list(pageLength = 10, language = list(url = '//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json')))
  
  output$tabla_estadisticas <- DT::renderDataTable({
    datos_carrera() %>%
      group_by(Anio) %>%
      summarise(Aspirantes = n(), Media = round(mean(Aciertos, na.rm = TRUE), 2), 
                Mediana = round(median(Aciertos, na.rm = TRUE), 2), SD = round(sd(Aciertos, na.rm = TRUE), 2)) %>%
      arrange(Anio)
  }, options = list(pageLength = 10, language = list(url = '//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json')))
}


#### app ####
shinyApp(ui, server)   
