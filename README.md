# Análisis de delitos violentos en Uruguay (2013–2024)

Este repositorio contiene un script en R con el objetivo de realizar un análisis descriptivo y territorial de la evolución de homicidios, rapiñas y violencia doméstica en Uruguay entre los años 2013 y 2024, utilizando datos oficiales del Ministerio del Interior y del Instituto Nacional de Estadística.

El análisis incluye:
- Evolución temporal a nivel nacional  
- Comparaciones interdepartamentales  
- Cálculo de variaciones anuales  
- Cálculo de tasas cada 100.000 habitantes  
- Visualización mediante gráficos y mapas departamentales  

---

## Contenido del repositorio

- `Script_analisis.R`  
  Script principal con todo el flujo de trabajo:
  - carga y limpieza de datos  
  - transformación y agregación  
  - cálculo de indicadores  
  - generación de gráficos y mapas  

---

## Paquetes utilizados

El script utiliza los siguientes paquetes de R:
- `r`
  - sf  
  - readr
  - readxl
  - tidyverse

---

## Fuentes de datos

### Delitos denunciados
- Observatorio Nacional sobre Violencia y Criminalidad – Ministerio del Interior
- Dataset: Delitos denunciados en el Uruguay
- Fuente: Catálogo de Datos Abiertos del Ministerio del Interior

### Población
- Instituto Nacional de Estadística (INE)
- Estimaciones y proyecciones de población por departamento

### Cartografía
- Archivo GeoJSON de límites departamentales de Uruguay
- Autor: Leandro Vieira (alotropico)
- Repositorio: uruguay.geo

---

## Descripción del análisis

El script realiza las siguientes etapas:

1. Carga de datos desde archivos CSV y XLSX  
2. Filtrado de delitos:
   - Homicidios  
   - Rapiñas  
   - Violencia doméstica  
3. Homogeneización de variables (departamentos, delitos y años)  
4. Agregación por departamento y año  
5. Cálculo de variaciones anuales:
   - por departamento  
   - a nivel nacional  
6. Cálculo de tasas departamentales cada 100.000 habitantes  
7. Identificación de años con valores máximos y mínimos por delito  
8. Visualización de resultados:
   - gráfico de líneas a nivel nacional (escala logarítmica)  
   - mapas coropléticos por departamento para el año 2024  

---

## Visuales generadas

- Evolución nacional de los delitos violentos 
- Tasa de homicidios por departamento   
- Tasa de violencia doméstica por departamento  
- Tasa de rapiñas por departamento 

Cada visual se puede hacer para el año deseado cambiando filter(AÑO == "20xx" ... )

---

## Cómo ejecutar el script

1. Clonar el repositorio o descargarlo como ZIP  
2. Abrir el archivo `Script_analisis.R` en RStudio
3. Ajustar las rutas de los archivos a la ubicación local de los datos  
4. Ejecutar el script completo  

> Importante: en el script uso rutas locales absolutas, que deben modificarse según el entorno del usuario.

---

## Notas

- El análisis que realizo es de carácter descriptivo y exploratorio 
- Los resultados dependen de la calidad y cobertura de los datos oficiales  
- El código fue desarrollado con fines académicos

---

## Autoría

Elaboración propia a partir de datos del Ministerio del Interior y el Instituto Nacional de Estadística.
Las bases de datos utilizadas se pueden encontrar en 
https://catalogodatos.gub.uy/dataset/ministerio-del-interior-delitos_denunciados_en_el_uruguay
