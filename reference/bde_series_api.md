# Load BdE time series from the Statistics web service (API)

**\[experimental\]**

These functions query BdE time series through the [Statistics web
service
(API)](https://www.bde.es/webbe/en/estadisticas/recursos/api-estadisticas-bde.html).

The API is a JSON web service that provides access through URL requests
to information available in the Statistics section of the Banco de
España and the BIEST application.

The API defines two request types. `bde_series_api_latest()` uses the
Latest Data request to obtain the latest published observation for one
or more series. `bde_series_api_load()` uses the Series List request to
obtain the details of one or more complete series and their metadata.

This API service uses the series alias as the identifier (see
[`vignette("csv_manual", package = "tidyBdE")`](https://ropenspain.github.io/tidyBdE/articles/csv_manual.md)).
The series alias is a positional code showing the location (column
and/or row) of the series in the table. However, although it is unique,
it is not a good candidate to be used as the series ID because it is
subject to change.

- If a series changes position in the table, its alias will also change.

- If a new series is inserted into a table, all the aliases that come
  after it will change and will not represent the same series.

## Usage

``` r
bde_series_api_latest(series_alias, language = c("en", "es"), verbose = FALSE)

bde_series_api_load(
  series_alias,
  series_label = NULL,
  out_format = "wide",
  parse_dates = TRUE,
  language = c("en", "es"),
  time_range = NULL,
  verbose = FALSE,
  extract_metadata = FALSE
)
```

## Arguments

- series_alias:

  Character string or vector of time series aliases from the
  `Nombre_de_la_serie` field of the corresponding series. See
  [`bde_catalog_load()`](https://ropenspain.github.io/tidyBdE/reference/bde_catalog_load.md).

- language:

  Character string. It can take the values `"es"` or `"en"` to obtain
  results in Spanish or English, respectively.

- verbose:

  Logical. If `TRUE`, display information useful for debugging.

- series_label:

  Optional character string or vector of labels to assign to the
  extracted series.

- out_format:

  The format to return, either `"wide"` or `"long"`. See **Value** for
  details and the **Examples** section.

- parse_dates:

  Logical. If `TRUE`, date columns are parsed with
  [`bde_parse_dates()`](https://ropenspain.github.io/tidyBdE/reference/bde_parse_dates.md).

- time_range:

  Character string. Optional annual range or API range code. It can be a
  year, such as `"2024"`, or a range code such as `"3M"`, `"12M"`,
  `"30M"`, `"36M"`, `"60M"` or `"MAX"`. If `NULL`, the API returns the
  smallest range for the series frequency. Range codes are validated
  against the frequency returned by `bde_series_api_latest()`.

- extract_metadata:

  Logical. If `TRUE`, the output is the metadata of the requested
  series.

## Value

`bde_series_api_latest()` returns a
[tibble](https://tibble.tidyverse.org/reference/tbl_df-class.html) with
the latest published observation for each valid series, with fields
returned by the Latest Data request such as `serie`, `descripcionCorta`,
`codFrecuencia`, `decimales`, `simbolo`, `tendencia`, `fechaValor` and
`valor`.

`bde_series_api_load()` returns a
[tibble](https://tibble.tidyverse.org/reference/tbl_df-class.html). When
`extract_metadata = FALSE`, it returns observations in wide or long
format according to `out_format`. When `extract_metadata = TRUE`, it
returns one row per valid series with fields returned by the Series List
request, including list columns for `informacion`, `fechas` and
`valores`.

## See also

[`bde_catalog_load()`](https://ropenspain.github.io/tidyBdE/reference/bde_catalog_load.md),
[`bde_catalog_search()`](https://ropenspain.github.io/tidyBdE/reference/bde_catalog_search.md),
[`bde_indicators()`](https://ropenspain.github.io/tidyBdE/reference/bde_indicators.md)

Other series:
[`bde_series_full_load()`](https://ropenspain.github.io/tidyBdE/reference/bde_series_full_load.md),
[`bde_series_load()`](https://ropenspain.github.io/tidyBdE/reference/bde_series_load.md)

## Examples

``` r
# \donttest{
xr <- bde_catalog_load(catalog = "TC")

# Extract the latest value.
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
xr |>
  slice_head(n = 3) |>
  pull(Nombre_de_la_serie) |>
  bde_series_api_latest(language = "en") |>
  glimpse()
#> Rows: 3
#> Columns: 8
#> $ serie            <chr> "DTCCBCEUSDEUR.B", "DTCCBCEJPYEUR.B", "DTCCBCECHFEUR.…
#> $ descripcionCorta <chr> "Exchange rate. US dollars per euro (USD/EUR). Daily …
#> $ codFrecuencia    <chr> "D", "D", "D"
#> $ decimales        <int> 4, 4, 4
#> $ simbolo          <chr> "USD", "JPY", "CHF"
#> $ tendencia        <chr> "-", "-", "+"
#> $ fechaValor       <date> 2026-06-10, 2026-06-10, 2026-06-10
#> $ valor            <dbl> 1.1539, 185.1900, 0.9222

# Extract the latest months.
xr |>
  slice_head(n = 1) |>
  pull(Nombre_de_la_serie) |>
  bde_series_api_load(language = "en", time_range = "12M") |>
  glimpse()
#> Error in tibble::tibble(Date = meta$fechas[[i]], serie_name = meta$serie_name[i],     serie_value = meta$valores[[i]]): Tibble columns must have compatible sizes.
#> • Size 262: Existing data.
#> • Size 256: Column `serie_value`.
#> ℹ Only values of size one are recycled.
# }
```
