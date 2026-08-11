# 🤖 IA Examen UNAM 2026 🤖


[![License: GPL v3](https://img.shields.io/badge/License-GPL_v3-blue.svg)](https://www.gnu.org/licenses/quick-guide-gplv3.html)
[![Shiny](https://img.shields.io/badge/Shiny-RStudio-blue.svg)](https://shiny.rstudio.com/)
![GitHub stars](https://img.shields.io/github/stars/jabpcomplex/dashbord_CRIMEN_CDMX?style=social)

<div align="center" style="background-color: white; padding: 10px; border-radius: 10px; display: flex;">
 <img src="https://raw.githubusercontent.com/jabpcomplex/ia-examen-unam-2026/refs/heads/main/scripts/dashboard/dashboard-unam-2026.png" alt="img_tablero"  height= "auto" weigth = "650">
</div>



## 📖 Descripción

Aplicación Shiny para visualizar aciertos y acreditación en carreras de la UNAM.
Este repositorio nace como respuesta a la necesidad de transparencia en el examen de admisión 2026 para el sistema escolarizado del nivel licenciatura dado que presenta un comportamiento atípico en muchas carreras, en contraste con el de años recientes de 2021 a 2025. Las pestañas *Comparativa Histórica* y *Detalles por año* del dashboard muestran visualmente este hecho, a saber, un desplazamiento anómalo en la distribución de frecuencias del número de aciertos que obtuvo un estudiante en el examen de 2026.

## 📜 Licenciaturas 🎓

1. ACTUARIA
2. ARQUITECTURA
3. ARQUITECTURA DE PAISAJE
4. CIENCIAS DE LA COMPUTACION
5. FISICA
6. MATEMATICAS
7. MATEMATICAS APLICADAS
8. URBANISMO


## 🚀 Características Principales

- **Visualización:** Dashboard interactivo con métricas clave.
- **Análisis Predictivo:** Modelos básicos para proyectar tendencias de aceptación.

## 🛠️ Tecnologías Utilizadas

- **Lenguaje:** R 
- **Librerías:** `tidyverse`, `ggplot2`, `shiny` (ajusta a las que usaste)
- **Entorno:** RStudio / Jupyter Notebooks
- **Control de Versiones:** Git & GitHub

## 📂 Estructura del Proyecto


```bash
├── data/ # Datos crudos y procesados
│ └── raw/ # Datos crudos
├── scripts/ # Código fuente (R) 
│ └── dashboard/ # Archivos del dashboard 
├── reports/ # Documentos y resultados 
└── README.md # Este archivo
```


## Instalación

1. Clona este repositorio.

```bash
git clone https://github.com/jabpcomplex/ia-examen-unam-2026.git   
```

2. Abre el archivo `.Rproj` en RStudio.
3. Instala dependencias:

```R
install.packages(c("shiny", "shinydashboard", "plotly", "tidyverse", "DT", "scales"))   
```






## 📜 Licencia

Este proyecto está bajo licencia GNU General Public License v3.0 

<div align="left" style="background-color: white; padding: 10px; border-radius: 10px; display: flex; align-items: center;">
  <a 
    href="https://www.gnu.org/licenses/gpl-3.0.html" 
    target="_blank" 
    rel="noopener noreferrer"
    title="Licencia GPLv3"
  >
    <img 
      src="https://upload.wikimedia.org/wikipedia/commons/9/93/GPLv3_Logo.svg" 
      alt="GPLv3 License" 
      height="80"
      style="transition: opacity 0.2s;"
      onmouseover="this.style.opacity='0.7'" 
      onmouseout="this.style.opacity='1'"
    >
  </a>
</div>

## 👤 Autor

<div align="left" style="background-color: white; padding: 10px; border-radius: 10px; display: flex; align-items: center;">
  <a 
    href="https://jabpcomplex.github.io/web-site-jabp/" 
    target="_blank" 
    rel="noopener noreferrer"
    title="Licencia GPLv3"
  >
    <img 
      src="https://raw.githubusercontent.com/jabpcomplex/jabpcomplex/refs/heads/main/jabpcomplex_automata_2.gif" 
      alt="logo_complex" 
      height="80"
      style="transition: opacity 0.2s;"
      onmouseover="this.style.opacity='0.7'" 
      onmouseout="this.style.opacity='1'"
    >
  </a>
</div>

## 📬 Contacto

📧 julioacustico10@gmail.com
