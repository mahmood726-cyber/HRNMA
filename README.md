# HRNMA

A single-file R Shiny application for **hazard-ratio (and other ratio-scale)
network meta-analysis (NMA)**, built on top of the
[`netmeta`](https://cran.r-project.org/package=netmeta) package.

## Overview

The app lets a user upload trial data (either arm-level or contrast-level),
runs a frequentist network meta-analysis with `netmeta::netmeta()`, and renders
the results interactively (network graph, forest plots, league tables, etc.).

- Contrast-level input is passed directly to `netmeta()` as
  `TE = te, seTE = sete, treat1, treat2, studlab` with a user-chosen summary
  measure `sm` (e.g. `HR`, `RR`, `OR`, `ROM`).
- Arm-level input is first converted to contrasts with
  `meta::pairwise()` before being fed to `netmeta()`.
- The effect estimate `te` is treated as a **log-scale** effect (e.g. log-HR);
  pooling is performed on the log scale and back-transformed for display.

The single application file is `app.R` (Shiny single-file convention: it defines
`ui`, `server`, and ends with `shinyApp(ui = ui, server = server)`).

## Requirements

This is a **server-side Shiny app** — it must be run in an interactive R/Shiny
session. It does not run as a static web page.

Install all packages the app loads:

```r
install.packages(c(
  "shiny", "bs4Dash", "shinycssloaders", "promises", "future",
  "netmeta", "visNetwork", "DT", "readr", "igraph", "dplyr"
))
```

Package status in the development environment used to revive this repo
(R 4.6.0):

| Installed                              | Not installed (required to run the app) |
| -------------------------------------- | --------------------------------------- |
| `netmeta`, `readr`, `igraph`, `dplyr`  | `shiny`, `bs4Dash`, `shinycssloaders`, `promises`, `future`, `visNetwork`, `DT` |

Because `shiny`, `bs4Dash`, and the other UI/async packages were not present,
the full app cannot be launched in that environment; only the statistical core
(`netmeta`) was exercised — see **Smoke test** below.

## Run

From the repository root, in an interactive R session:

```r
shiny::runApp(".")
```

(`runApp` looks for `app.R` in the working directory.)

## Smoke test

`test_nma.R` exercises the statistical engine the app relies on, independent of
Shiny. It pushes a tiny known 3-treatment log-HR network through
`netmeta::netmeta()` (the same call the app makes) and asserts basic properties:
treatment count, finite pooled `TE.common` / `TE.random`, anti-symmetric
contrast matrices, and a finite, non-negative `Q`.

```
& "C:\Program Files\R\R-4.6.0\bin\Rscript.exe" test_nma.R
```

It prints `NMA SMOKE TEST PASSED` and exits 0 when the engine behaves as
expected. It does **not** load Shiny or start the app server.

## Verify the app parses

```
& "C:\Program Files\R\R-4.6.0\bin\Rscript.exe" -e "invisible(parse('app.R')); cat('PARSES OK')"
```
