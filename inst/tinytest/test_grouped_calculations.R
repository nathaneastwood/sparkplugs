res <- summarise_groups(
  .data = mtcars,
  .groups = c("am", "cyl"),
  avgMpg = mean(mpg, na.rm = TRUE),
  avgDisp = mean(disp)
)
expect_equal(
  colnames(res),
  c("am", "cyl", "avgMpg", "avgDisp"),
  info = "Ensure all columns are created"
)
expect_equal(
  res$avgMpg,
  c(22.9, 19.125, 15.05, 28.075, 20.5666666666667, 15.4),
  info = "Ensure the mean is calculated per group"
)

res <- mutate_groups(
  .data = mtcars,
  .groups = c("am", "cyl"),
  avgMpg = mean(mpg, na.rm = TRUE),
  avgMpg2 = avgMpg * 2
)
expect_equal(
  colnames(res),
  c("mpg", "cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "am", "gear", "carb", "avgMpg", "avgMpg2"),
  info = "Ensure all columns are created"
)
expect_equal(
  res$avgMpg,
  c(
    20.5666666666667, 20.5666666666667, 28.075, 19.125, 15.05, 19.125, 15.05, 22.9, 22.9, 19.125, 19.125, 15.05, 15.05,
    15.05, 15.05, 15.05, 15.05, 28.075, 28.075, 28.075, 22.9, 15.05, 15.05, 15.05, 15.05, 28.075, 28.075, 28.075, 15.4,
    20.5666666666667, 15.4, 28.075
  ),
  info = "Ensure the mean is calculated per group"
)

res <- mutate_groups(.data = mtcars, .groups = "am", avgMpg = mean(mpg), .before = mpg)
expect_equal(
  colnames(res)[1],
  "avgMpg",
  info = "Additional arguments can still be passed"
)

# -- Spark ---------------------------------------------------------------------

if (identical(as.logical(Sys.getenv("NOT_ON_CRAN")), TRUE)) {
  invisible(suppressMessages(sc <- sparklyr::spark_connect(master = "local")))
  mtcars <- dplyr::copy_to(sc, mtcars, "mtcars")

  res <- summarise_groups(
    .data = mtcars,
    .groups = c("am", "cyl"),
    avgMpg = mean(mpg, na.rm = TRUE),
    avgDisp = mean(disp, na.rm = TRUE)
  )
  expect_true(inherits(res, "tbl_spark"))
  expect_equal(
    colnames(res),
    c("am", "cyl", "avgMpg", "avgDisp"),
    info = "Ensure all columns are created"
  )
  expect_equal(
    dplyr::pull(res, avgMpg),
    c(15.4, 15.05, 22.9, 20.5666666666667, 28.075, 19.125),
    info = "Ensure the mean is calculated per group"
  )

  res <- mutate_groups(
    .data = mtcars,
    .groups = c("am", "cyl"),
    avgMpg = mean(mpg, na.rm = TRUE),
    avgMpg2 = avgMpg * 2
  )
  expect_true(inherits(res, "tbl_spark"))
  expect_equal(
    colnames(res),
    c("mpg", "cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "am", "gear", "carb", "avgMpg", "avgMpg2"),
    info = "Ensure all columns are created"
  )
  expect_equal(
    dplyr::pull(res, avgMpg),
    c(
      15.4, 15.4, 22.9, 22.9, 22.9, 15.05, 15.05, 15.05, 15.05, 15.05, 15.05, 15.05, 15.05, 15.05, 15.05, 15.05, 15.05,
      19.125, 19.125, 19.125, 19.125, 28.075, 28.075, 28.075, 28.075, 28.075, 28.075, 28.075, 28.075, 20.5666666666667,
      20.5666666666667, 20.5666666666667
    ),
    info = "Ensure the mean is calculated per group"
  )

  rm(res)
  sparklyr::spark_disconnect_all()
}
