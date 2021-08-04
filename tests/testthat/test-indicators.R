test_that("Indicators", {
  skip_if_not(
    tidyBdE:::bde_check_access(),
    "Skipping... BdE not reachable."
  )

  # Test indicators----
  expect_silent(bde_ind_gdp_var())
  expect_silent(bde_ind_unemployment_rate())
  expect_silent(bde_ind_euribor_12m_monthly())
  expect_silent(bde_ind_euribor_12m_daily())
  expect_silent(bde_ind_cpi_var())
  expect_silent(bde_ind_ibex())
  expect_silent(bde_ind_gdp_quarterly())
  expect_silent(bde_ind_population())
})