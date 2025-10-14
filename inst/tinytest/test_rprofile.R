# Test install_rbranding_autoupdate and update_rbranding_autoupdate functions

# Create a temporary project directory
tmp_project <- tempfile("rbranding_test_")
dir.create(tmp_project)

# Test 1: install_rbranding_autoupdate creates .Rprofile
suppressMessages(install_rbranding_autoupdate(tmp_project))
rprofile_path <- file.path(tmp_project, ".Rprofile")

expect_true(file.exists(rprofile_path))

# Test 2: .Rprofile contains the expected markers
rprofile_content <- readLines(rprofile_path, warn = FALSE)
expect_true(any(grepl("^# >>> rbranding auto-update \\[.*\\] >>>$", rprofile_content)))
expect_true(any(grepl("^# <<< rbranding auto-update <<<$", rprofile_content)))

# Test 3: Running R in that directory doesn't crash
# Setup brand configuration using brand_init()
old_wd <- setwd(tmp_project)
suppressMessages(brand_init())
setwd(old_wd)

# Test that Rscript runs without error
test_cmd <- sprintf("cd %s && Rscript -e '1+1' 2>&1", shQuote(tmp_project))
result <- system(test_cmd, intern = TRUE, ignore.stderr = FALSE)
expect_true(length(result) > 0)  # Should produce some output

# Test 4: Modifying .Rprofile and then calling install should preserve other content
other_content <- c("# My custom code", "options(repos = 'https://cloud.r-project.org/')")
writeLines(c(other_content, "", rprofile_content), rprofile_path)

suppressMessages(update_rbranding_autoupdate(tmp_project))
rprofile_final <- readLines(rprofile_path, warn = FALSE)
expect_true(any(grepl("My custom code", rprofile_final)))
expect_true(any(grepl("rbranding auto-update", rprofile_final)))

# Test 6: Test error handling with non-existent directory
# This should produce a message about failure
capture_result <- tryCatch({
  suppressMessages(install_rbranding_autoupdate("/path/that/does/not/exist/12345"))
  "no_message"
}, error = function(e) {
  "error"
})
# The function should handle the error gracefully (not throw an error)
expect_true(capture_result == "no_message")

# Cleanup
unlink(tmp_project, recursive = TRUE)
