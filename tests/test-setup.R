testthat::test_that("test setup has expected capsule files", {
  repo_root <- normalizePath(file.path(testthat::test_path(), "..", ".."))

  testthat::expect_true(file.exists(file.path(repo_root, "code", "main.R")))
  testthat::expect_true(file.exists(file.path(repo_root, "code", "run")))
  testthat::expect_true(file.exists(file.path(repo_root, ".codeocean", "app-panel.json")))
})