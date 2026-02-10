# Paquetes a usar
library(sf)
library(readr)
library(readxl)
library(tidyverse)

# Abrir csv de otros delitos
otrosdel <- read_delim("/Users/guillelore/Desktop/Scripts R/Trabajo Final R/otros-delitos.csv", delim = ";")
# Abrir xlsx de homicidios
homicidios <- read_excel("/Users/guillelore/Desktop/Scripts R/Trabajo Final R/homicidios_dolosos_consumados.xlsx")
# Fuente: Observatorio Nacional sobre Violencia y Criminalidad - Ministerio del Interior
# https://catalogodatos.gub.uy/dataset/ministerio-del-interior-delitos_denunciados_en_el_uruguay

# Busqueda de casos perdidos
table(is.na(otrosdel)) # False
table(is.na(homicidios)) # False

# División según delitos
rapinas <- otrosdel %>% # Objeto de rapinas
  filter(DELITO == "RAPIÑA")
v_domestica <- otrosdel %>% # Objeto de violencia domestica
  filter(DELITO == "VIOLENCIA DOMÉSTICA")

# Desagregación por dpto
homicidios <- homicidios %>%  
  rename(DEPTO = DEPARTAMENTO) %>% # Recodificacion de columna DEPARTAMENTO para que sea igual a la de los otros delitos
  mutate(DELITO = case_when( # Creacion de variable delito para facilitar el conteo con los otros objetos de delitos
    SEXO == "HOMBRE" ~ "HOMICIDIO",
    SEXO == "MUJER" ~ "HOMICIDIO",
    SEXO == "SIN DATO" ~ "HOMICIDIO"
  ))

delitos <- bind_rows(homicidios, rapinas, v_domestica) # Uno los objetos de cada uno de los delitos

delitos <- delitos %>% # Completo años faltantes por no tener casos
  complete(DEPTO, DELITO, AÑO = full_seq(AÑO, 1),
           fill = list(casos = 0))

delitos <- delitos %>% # Diferenciacion de filas de casos reales de filas por años sin casos
  mutate(casos_reales = ifelse(is.na(MES), NA, 1))

del_por_depyano <- delitos %>% # Agrupo los delitos por año y departamento para observar su evolución temporal y territorial.
  group_by(DEPTO, AÑO, DELITO) %>%
  filter(AÑO <= 2024) %>%
  summarise(casos = sum(casos_reales, na.rm = TRUE))

# Calculo de variación anual
var_dep_del <- del_por_depyano %>% # Variacion anual de cada delito por depto 
  group_by(DEPTO, DELITO) %>%
  arrange(DELITO) %>%
  mutate(variacion_anual = (casos - lag(casos))/lag(casos) * 100)

variacion_interdepto <- del_por_depyano %>% # Variacion interdepartamental promedio por año (idea y código originado por ChatGPT)
  group_by(AÑO, DELITO) %>%
  summarise(media = mean(casos, na.rm = TRUE),desv = sd(casos, na.rm = TRUE),coef_var = (desv / media) * 100)

var_nac_del <- del_por_depyano %>% # Variacion anual de cada delito a nivel nacional
  group_by(DELITO, AÑO) %>%
  summarise(casos_totales = sum(casos, na.rm = TRUE)) %>%
  arrange(DELITO, AÑO) %>%
  group_by(DELITO) %>%
  mutate(variacion_anual = (casos_totales - lag(casos_totales)) / lag(casos_totales) * 100)

# Detectar casos y años maximos y minimos
del_maxymin_depto <- del_por_depyano %>% # Objeto de máximos y mínimos de delitos por depto
  group_by(DEPTO, DELITO) %>%
  summarise(año_max = AÑO[which.max(casos)], 
            casos_max = max(casos), 
            año_min = AÑO[which.min(casos)], 
            casos_min = min(casos))

del_maxymin_nac <- var_nac_del %>% # Objeto de máximos y mínimos de delitos a nivel nacional.
  group_by(DELITO) %>%
  summarise(año_pico = AÑO[which.max(casos_totales)],
            max_casos = max(casos_totales),
            año_minimo = AÑO[which.min(casos_totales)],
            min_casos = min(casos_totales))

# Cálculo de tasas departamentales
pobl <- read_excel("/Users/guillelore/Desktop/Scripts R/Trabajo Final R/pobl departamental.xlsx")
# Fuente: Instituto Nacional de Estadística
# https://www.gub.uy/instituto-nacional-estadistica/estimaciones_proyecciones

pobl_largo <- pobl %>% # Paso el objeto de poblacion a formato largo para poder combinarla con otros objetos
  pivot_longer(cols = "2013.0":"2024.0",
               names_to = "AÑO",
               values_to = "POBL") %>%
  mutate(AÑO = as.numeric(AÑO))

del_tasas <- del_por_depyano %>% # Uno los dos objetos por sus variables en común
  left_join(pobl_largo, by = c("DEPTO", "AÑO"))

del_tasas <- del_tasas %>% # Calculo de tasas departamentales cada 100.000 habitantes
  mutate(tasa_100000 = (casos / POBL) * 100000)

del_tasas <- del_tasas %>% # Limito la cantidad de numeros decimales para que se vea más prolijo
  mutate(tasa_100000 = round(tasa_100000, 1))

# Grafico departamental e histograma nacional
mapa_uy <- st_read("/Users/guillelore/Desktop/Scripts R/Trabajo Final R/uruguay.geojson")
# Fuente: "json y topoJson de Uruguay, con límites departamentales." de Leandro Vieira (alotropico)
# https://github.com/alotropico/uruguay.geo/blob/master/README.md

mapa_uy <- mapa_uy %>% # Recodificacion de variable NAME_1 para que coincida con los otros objetos
  rename(DEPTO = NAME_1) %>%
  mutate(DEPTO = case_when(
    DEPTO == "Artigas" ~ "ARTIGAS",
    DEPTO == "Canelones" ~ "CANELONES",
    DEPTO == "Cerro Largo" ~ "CERRO LARGO",
    DEPTO == "Colonia" ~ "COLONIA",
    DEPTO == "Durazno" ~ "DURAZNO",
    DEPTO == "Flores" ~ "FLORES",
    DEPTO == "Florida" ~ "FLORIDA",
    DEPTO == "Lavalleja" ~ "LAVALLEJA",
    DEPTO == "Maldonado" ~ "MALDONADO",
    DEPTO == "Montevideo" ~ "MONTEVIDEO",
    DEPTO == "Paysandú" ~ "PAYSANDU",
    DEPTO == "Río Negro" ~ "RIO NEGRO",
    DEPTO == "Rivera" ~ "RIVERA",
    DEPTO == "Rocha" ~ "ROCHA",
    DEPTO == "Salto" ~ "SALTO",
    DEPTO == "San José" ~ "SAN JOSE",
    DEPTO == "Soriano" ~ "SORIANO",
    DEPTO == "Tacuarembó" ~ "TACUAREMBO",
    DEPTO == "Treinta y Tres" ~ "TREINTA Y TRES"
  ))

mapa_tasas <- mapa_uy %>% # Union de objetos para graficar
  left_join(del_tasas, by = "DEPTO")

# Gráfico 1. Evolución de rapiñas, homicidios y violencia doméstica a nivel nacional (2013-2024)
ggplot(var_nac_del, aes(x = AÑO, y = casos_totales, color = DELITO)) + # Grafico de lineas de la evolucion a nivel nacional de los 3 delitos.
  geom_line() +
  geom_point(size = 2) +
  scale_y_log10() +
  labs(title = "Evolución nacional de los delitos violentos (2013–2024)",
       x = "Año",
       y = "Cantidad de casos",
       color = "Delito")

# Gráfico 2. Evolución de las tasas de homicidios dolosos (2013–2024)
ggplot(mapa_tasas %>% filter(AÑO == 2024, DELITO == "HOMICIDIO")) + 
  geom_sf(aes(fill = tasa_100000), color = "black", size = 0.2) +
  scale_fill_gradient(limits = c(0, max(subset(mapa_tasas, DELITO == "HOMICIDIO")$tasa_100000)), low = "white", high = "black", name = "Tasa por 100.000 hab.") +
  labs(title = "Tasa de Homicidios por Departamento (2024)",
       caption = "Fuente: elaboración propia con base en datos del MI e INE") +
  theme_minimal()

# Gráfico 3. Evolución de las tasas de violencia doméstica (2013–2024)
ggplot(mapa_tasas %>% filter(AÑO == 2024, DELITO == "VIOLENCIA DOMÉSTICA")) + 
  geom_sf(aes(fill = tasa_100000), color = "black", size = 0.2) +
  scale_fill_gradient(limits = c(0, max(subset(mapa_tasas, DELITO == "VIOLENCIA DOMÉSTICA")$tasa_100000)), low = "white", high = "red", name = "Tasa por 100.000 hab.") +
  labs(title = "Tasa de Violencia Doméstica por Departamento (2024)",
       caption = "Fuente: elaboración propia con base en datos del MI e INE") +
  theme_minimal()

# Gráfico 4. Evolución de las tasas de rapiñas (2013–2024)
ggplot(mapa_tasas %>% filter(AÑO == 2024, DELITO == "RAPIÑA")) + 
  geom_sf(aes(fill = tasa_100000), color = "black", size = 0.2) +
  scale_fill_gradient(limits = c(0, max(subset(mapa_tasas, DELITO == "VIOLENCIA DOMÉSTICA")$tasa_100000)), low = "white", high = "blue", name = "Tasa por 100.000 hab.") +
  labs(title = "Tasa de Rapiñas por Departamento (2024)",
       caption = "Fuente: elaboración propia con base en datos del MI e INE") +
  theme_minimal()

# Fuente: Elaboración propia con base en Observatorio Nacional sobre Violencia y Criminalidad (MI)