# Anexo técnico: Intento de Web Scraping de resultados UNAM (R)

## Objetivo

Desarrollar un scraper en R para extraer las columnas:

-   Número de comprobante
-   Aciertos
-   Acreditado
-   Detalles

desde las páginas de resultados de admisión de la UNAM.

------------------------------------------------------------------------

# Arquitectura inicial

Se propuso utilizar:

-   xml2
-   rvest
-   httr2
-   curl

Flujo esperado:

1.  Descargar el HTML.
2.  Localizar el `<tbody>`.
3.  Extraer cada `<tr>`.
4.  Leer las cuatro columnas `<td>`.
5.  Construir un `data.frame`.

El algoritmo de extracción era correcto y asumía que el HTML era
accesible.

------------------------------------------------------------------------

# Error 1: read_html()

Código:

``` r
pagina <- read_html(url)
```

Error:

``` text
Error in open.connection(x, "rb"):
no se puede abrir la conexión
```

## Diagnóstico

Aunque el mensaje parecía indicar un problema de conectividad, en
realidad era un error genérico generado porque el servidor rechazaba la
solicitud HTTP.

Conclusión: el problema no estaba en `xml2` ni en `rvest`.

------------------------------------------------------------------------

# Error 2: Uso de httr2

Se sustituyó `read_html()` por una solicitud HTTP explícita.

``` r
request(url) |>
    req_perform()
```

Resultado:

``` text
HTTP 403 Forbidden
```

## Diagnóstico

La conectividad existía, pero el servidor denegó el acceso antes de
entregar el HTML.

Esto descartó problemas de DNS, SSL o URL inexistente.

------------------------------------------------------------------------

# Error 3: Simulación de un navegador

Se añadieron encabezados HTTP:

-   User-Agent
-   Accept
-   Accept-Language
-   Referer
-   Connection

Resultado:

``` text
HTTP 403 Forbidden
```

## Diagnóstico

Muchos servidores aceptan solicitudes únicamente cuando detectan un
navegador. Sin embargo, en este caso el simple cambio de cabeceras no
fue suficiente.

------------------------------------------------------------------------

# Error 4: Inspección con curl

Se inspeccionó el contenido devuelto por el servidor.

Resultado:

``` html
<title>Just a moment...</title>
```

También aparecieron las cabeceras:

``` text
server: cloudflare
cf-mitigated: challenge
```

## Diagnóstico

El servidor no devolvió la página de resultados.

En su lugar respondió con una página de desafío ("challenge") generada
por Cloudflare.

------------------------------------------------------------------------

# Error 5: Inspección de cabeceras HTTP

Respuesta resumida:

``` text
HTTP/2 403

server: cloudflare

cf-mitigated: challenge
```

## Interpretación

La solicitud nunca llegó al servidor de la UNAM.

El tráfico fue interceptado previamente por Cloudflare.

------------------------------------------------------------------------

# Análisis técnico del desafío

El desafío "Just a moment..." es un mecanismo de protección diseñado
para verificar que el cliente sea un navegador legítimo.

Durante este proceso Cloudflare puede:

-   ejecutar JavaScript;
-   generar cookies temporales;
-   analizar la huella TLS;
-   verificar características del navegador;
-   medir el comportamiento de la sesión.

Una biblioteca HTTP tradicional no ejecuta ese proceso, por lo que
recibe un código 403.

------------------------------------------------------------------------

# ¿Por qué rvest no puede resolver este problema?

`rvest` descarga HTML estático.

No ejecuta JavaScript.

No mantiene una sesión de navegador completa.

No supera desafíos interactivos de Cloudflare.

Por ello nunca recibe el documento HTML que contiene la tabla buscada.

------------------------------------------------------------------------

# ¿Qué herramientas fueron evaluadas?

  Herramienta       Resultado
  ----------------- ------------------------------------
  xml2::read_html   Error de conexión derivado del 403
  rvest             No obtiene el HTML
  httr2             HTTP 403
  curl              Challenge de Cloudflare

Todas fallaron por la misma causa: la protección del sitio, no por
errores de programación.

------------------------------------------------------------------------

# Conclusión técnica

El algoritmo de extracción basado en `<tbody>`, `<tr>` y `<td>` es
válido y probablemente funcionaría si el HTML fuera accesible.

El obstáculo se encuentra antes de la etapa de parsing: Cloudflare
impide que un cliente HTTP convencional obtenga el documento.

Por ello, el problema no debe abordarse modificando el parser, sino
cambiando el mecanismo de acceso.

------------------------------------------------------------------------

# Recomendación

La alternativa más robusta es utilizar un navegador automatizado (por
ejemplo, Playwright o Selenium). Estas herramientas controlan un
navegador real, ejecutan JavaScript, mantienen la sesión y pueden
superar los desafíos que preceden a la entrega del HTML cuando ello
ocurre como parte normal de la navegación.

Una vez obtenido el HTML, la lógica de extracción diseñada inicialmente
en R sigue siendo aplicable.
