# test_nma.R
# Stat-core smoke test for the HRNMA Shiny app's network meta-analysis engine.
#
# The app feeds contrast-level data (log-HR effect = te, standard error = sete,
# treat1/treat2/studlab) into netmeta::netmeta() with sm = "HR" (see app.R, the
# `netmeta(TE = te, seTE = sete, treat1 = treat1, treat2 = treat2, studlab = ...)`
# call). This test exercises that same engine with a tiny, known 3-treatment
# network and asserts basic structural/numeric properties. It does NOT load
# shiny/bs4Dash and does NOT start the app server.
#
# Run:  & "C:\Program Files\R\R-4.6.0\bin\Rscript.exe" test_nma.R

suppressPackageStartupMessages(library(netmeta))

# A small connected network over 3 treatments: A (reference), B, C.
# Effects are on the log-HR scale (sm = "HR"), exactly as the app passes them.
dat <- data.frame(
  studlab = c("S1", "S2", "S3", "S4"),
  treat1  = c("A",  "A",  "B",  "A"),
  treat2  = c("B",  "C",  "C",  "B"),
  te      = c(-0.30, -0.50, -0.15, -0.25),  # log hazard ratios
  sete    = c(0.10,  0.12,  0.11,  0.13),    # standard errors of the log-HRs
  stringsAsFactors = FALSE
)

net <- netmeta(
  TE = te, seTE = sete,
  treat1 = treat1, treat2 = treat2, studlab = studlab,
  data = dat,
  sm = "HR",
  common = TRUE, random = TRUE,
  reference.group = "A"
)

# ---- Assertions -----------------------------------------------------------

# 1. Number of treatments recovered from the contrasts.
stopifnot(net$n == 3)
stopifnot(setequal(net$trts, c("A", "B", "C")))

# 2. Number of pairwise comparisons (rows) preserved.
stopifnot(net$m == nrow(dat))

# 3. Pooled relative-effect matrices are finite (common + random).
stopifnot(all(is.finite(net$TE.common)))
stopifnot(all(is.finite(net$TE.random)))

# 4. Contrast (relative-effect) matrix is anti-symmetric: TE[i,j] = -TE[j,i],
#    and the diagonal (treatment vs itself) is zero.
stopifnot(max(abs(net$TE.common + t(net$TE.common))) < 1e-8)
stopifnot(max(abs(diag(net$TE.common))) < 1e-8)
stopifnot(max(abs(net$TE.random + t(net$TE.random))) < 1e-8)

# 5. Heterogeneity / inconsistency statistic Q is finite and non-negative.
stopifnot(is.finite(net$Q))
stopifnot(net$Q >= 0)

# 6. Pooled standard errors are finite and the diagonal is zero
#    (a treatment compared with itself has no uncertainty).
stopifnot(all(is.finite(net$seTE.common)))
stopifnot(max(abs(diag(net$seTE.common))) < 1e-8)

cat("NMA SMOKE TEST PASSED\n")
cat(sprintf("  treatments (n) = %d : %s\n", net$n, paste(net$trts, collapse = ", ")))
cat(sprintf("  comparisons (m) = %d\n", net$m))
cat(sprintf("  Q = %.4f (df = %d)\n", net$Q, net$df.Q))
cat(sprintf("  log-HR B vs A (common) = %.4f\n", net$TE.common["B", "A"]))
cat(sprintf("  log-HR C vs A (random) = %.4f\n", net$TE.random["C", "A"]))
