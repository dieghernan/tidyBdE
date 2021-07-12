
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tidyBdE <img src="man/figures/logo.png" align="right" width="120"/>

<!-- badges: start -->

[![rOS-badge](https://ropenspain.github.io/rostemplate/reference/figures/ropenspain-badge.svg)](https://ropenspain.es/)
[![CRAN-status](https://www.r-pkg.org/badges/version/tidyBdE)](https://CRAN.R-project.org/package=tidyBdE)
[![CRAN-results](https://cranchecks.info/badges/worst/tidyBdE)](https://cran.r-project.org/web/checks/check_results_tidyBdE.html)
[![On-CRAN](https://www.r-pkg.org/badges/ago/tidyBdE)](https://cran.r-project.org/web/checks/check_results_tidyBdE.html)
[![R-CMD-check](https://github.com/rOpenSpain/tidyBdE/actions/workflows/check-full.yaml/badge.svg)](https://github.com/rOpenSpain/tidyBdE/actions/workflows/check-full.yaml)
[![codecov](https://codecov.io/gh/ropenspain/tidyBdE/branch/main/graph/badge.svg)](https://codecov.io/gh/ropenspain/tidyBdE)
![GitHub-version](https://img.shields.io/github/r-package/v/ropenspain/tidyBdE?label=dev)
[![DOI](https://img.shields.io/badge/DOI-10.5281/zenodo.4673496-blue)](https://doi.org/10.5281/zenodo.4673496)
[![Downloads](http://cranlogs.r-pkg.org/badges/grand-total/tidyBdE?color=blue)](https://cran.r-project.org/package=tidyBdE)

<!-- badges: end -->

**tidyBdE** is an API package that helps to retrieve data from [Banco de
España](https://www.bde.es/webbde/en/estadis/infoest/descarga_series_temporales.html).
The data is provided as [tibble](https://tibble.tidyverse.org/) and the
package tries to guess the format of every time-series (dates,
characters and numbers).

## Installation

Install **tidyBdE** from
[**CRAN**](https://CRAN.R-project.org/package=tidyBdE):

``` r
install.packages("tidyBdE")
```

You can install the developing version of **tidyBdE** with:

``` r
library(remotes)

install_github("ropenspain/tidyBdE")
```

## Examples

Banco de España (**BdE**) provides several time-series, either produced
by the institution itself or compiled for another sources, as
[Eurostat](https://ec.europa.eu/eurostat) or [INE](https://www.ine.es/).

The basic entry point for searching time-series are the catalogs
(*indexes*) of information. You can search any series by name:

``` r
library(tidyBdE)

# Search GBP on "TC" (exchange rate) catalog
XR_GBP <- bde_catalog_search("GBP", catalog = "TC")

XR_GBP[c(2, 5)]
#> # A tibble: 1 x 2
#>   Numero_secuencial Descripcion_de_la_serie                                     
#>               <dbl> <chr>                                                       
#> 1            573214 Tipo de cambio. Libras esterlinas por euro (GBP/EUR).Datos ~
```

**Note that BdE files are only provided in Spanish, for the time
being**, the organism is working on the English version. By now, search
terms should be provided in Spanish in order to get search results.

After we have found our series, we can load the series for the GBP/EUR
exchange rate using the sequential number reference
(`Numero_Secuencial`) as:

``` r
# Load tidyverse for better handling
library(tidyverse)

time_series <- bde_series_load(573214, series_label = "EUR_GBP_XR") %>%
  filter(Date >= "2010-01-01" & Date <= "2020-12-31") %>%
  drop_na()
```

The package also provides a custom `ggplot2` theme based on the
publications of BdE:

``` r
ggplot(time_series, aes(x = Date, y = EUR_GBP_XR)) +
  geom_line(colour = bde_vivid_pal()(1)) +
  geom_smooth(method = "gam", colour = bde_vivid_pal()(2)[2]) +
  labs(
    title = "EUR/GBP Exchange Rate (2010-2020)",
    subtitle = "%",
    caption = "Source: BdE"
  ) +
  geom_vline(
    xintercept = as.Date("2016-06-23"),
    linetype = "dotted"
  ) +
  geom_label(aes(
    x = as.Date("2016-06-23"),
    y = .95,
    label = "Brexit"
  )) +
  coord_cartesian(ylim = c(0.7, 1)) +
  theme_bde()
#> `geom_smooth()` using formula 'y ~ s(x, bs = "cs")'
```

<img src="man/figures/README-chart-1.png" width="100%" />

The package provides also several “shortcut” functions for a selection
of the most relevant macroeconomic series, so there is no need to look
for them in advance:

``` r
gdp <- bde_ind_gdp_var("values")
gdp$label <- "GDP YoY"

UnempRate <- bde_ind_unemployment_rate("values")
UnempRate$label <- "Unemployment Rate"

plotseries <- bind_rows(gdp, UnempRate) %>%
  drop_na() %>%
  filter(Date >= "2010-01-01" & Date <= "2019-12-31")

ggplot(plotseries, aes(x = Date, y = values)) +
  geom_line(aes(color = label)) +
  labs(
    title = "Spanish Economic Indicators (2010-2019)",
    subtitle = "%",
    caption = "Source: BdE"
  ) +
  theme_bde() +
  scale_color_bde_d(palette = "bde_vivid_pal") # Custom palette on the package
```

<img src="man/figures/README-macroseries-1.png" width="100%" />

Two custom palettes, based on the used by BdE on some publications are
available.

``` r
opar <- par(no.readonly = TRUE)

par(mfrow = c(1, 2))
scales::show_col(bde_rose_pal()(6))
title("bde_rose_pal()")
scales::show_col(bde_vivid_pal()(6))
title("bde_vivid_pal()")
```

<img src="man/figures/README-palettes-1.png" width="100%" />

``` r
par(opar)
```

Those palettes can be applied to a `ggplot2` using some custom utils
included on the package (see
`help("scale_color_bde_d", package = "tidyBdE")`).

``` r
# Load GDP Series

GDP <- bde_series_load(
  series_code = c(
    3777251,
    3777265,
    3777259,
    3777269,
    3777060
  ),
  series_label = c(
    "Agriculture",
    "Industry",
    "Construction",
    "Services",
    "Total"
  )
)


# Manipulate data - tidyverse style

GDP_all <- GDP %>%
  # Filter dates
  filter(Date <= "2020-12-31") %>%
  # Create 'Other' column and convert Date to year
  mutate(
    Other = Total - rowSums(across(Agriculture:Services)),
    Date = as.numeric(format(Date, format = "%Y"))
  ) %>%
  # Sum by year
  group_by(Date) %>%
  summarise_at(vars(-group_cols()), sum) %>%
  # Create percentage
  relocate(Total, .after = Other) %>%
  mutate(across(Agriculture:Other, ~ .x * 100 / Total)) %>%
  # Move cols to rows for plotting
  select(-Total) %>%
  pivot_longer(Agriculture:Other,
    names_to = "serie",
    values_to = "value"
  )



ggplot(data = GDP_all, aes(
  x = Date,
  y = value,
  fill = serie
)) +
  geom_bar(
    position = "stack",
    stat = "identity",
    alpha = 0.8
  ) +
  scale_fill_bde_d(palette = "bde_rose_pal") + # Custom palette on the package
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  theme_bde() +
  labs(
    title = "Spain: Gross domestic product by industry",
    subtitle = "%",
    caption = "Source: BdE"
  )
```

<img src="man/figures/README-gdp-1.png" width="100%" />

### A note on caching

You can use **tidyBdE** to create your own local repository at a given
local directory passing the following option:

``` r
options(bde_cache_dir = "./path/to/location")
```

When this option is set, **tidyBdE** would look for the cached file on
the `bde_cache_dir` directory and it will load it, speeding up the
process.

It is possible to update the data (i.e. after every monthly or quarterly
data release) with the following commands:

``` r
bde_catalog_update()

# On most of the functions using the option update_cache = TRUE

bde_series_load("SOME ID", update_cache = TRUE)
```

## Another R packages for downloading Spanish open data

Other useful packages that provides access to Spanish open data:

-   [**MicroDatosEs**](https://github.com/rOpenSpain/MicroDatosEs): A
    package that process microdata provided by Spanish statistical
    agencies (mostly, INE).
-   [**CatastRo**](https://github.com/rOpenSpain/CatastRo): A package
    that queries Sede electrónica del Catastro API.
-   [**mapSpain**](https://ropenspain.github.io/mapSpain/): For
    downloading geospatial information from Instituto Geográfico
    Nacional (IGN) and creating maps of Spain.

## Disclaimer

This package is in no way sponsored endorsed or administered by Banco de
España.