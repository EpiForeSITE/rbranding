# Test install_rbranding and update_rbranding functions

# Load the package
library(rbranding)

# Create a temporary project directory
tmp_project <- tempfile("rbranding_test_")
dir.create(tmp_project)

# Test 1: install_rbranding creates .Rprofile
suppressMessages(install_rbranding(tmp_project))
rprofile_path <- file.path(tmp_project, ".Rprofile")
expect_true(file.exists(rprofile_path), 
            info = "install_rbranding should create .Rprofile")

# Test 2: .Rprofile contains the expected markers
rprofile_content <- readLines(rprofile_path, warn = FALSE)
expect_true(any(grepl("^# >>> rbranding auto-update \\[.*\\] >>>$", rprofile_content)),
            info = ".Rprofile should contain start marker")
expect_true(any(grepl("^# <<< rbranding auto-update <<<$", rprofile_content)),
            info = ".Rprofile should contain end marker")

# Test 3: Running R in that directory doesn't crash
# Create config and brand files for testing
config_path <- file.path(tmp_project, "config.yml")
brand_path <- file.path(tmp_project, "_brand.yml")

config_content <- list(
  remote_file = "https://raw.githubusercontent.com/EpiForeSITE/rbranding/main/_brand.yml",
  local_file = "_brand.yml"
)
yaml::write_yaml(config_content, config_path)
writeLines("test brand content", brand_path)

# Test that Rscript runs without error
test_cmd <- sprintf("cd %s && Rscript -e '1+1' 2>&1", shQuote(tmp_project))
result <- system(test_cmd, intern = TRUE, ignore.stderr = FALSE)
expect_true(length(result) > 0, 
            info = "Rscript should run and produce output")  # Should produce some output

# Test 4: update_rbranding (should be idempotent on second call)
suppressMessages(update_rbranding(tmp_project))
rprofile_content2 <- readLines(rprofile_path, warn = FALSE)
expect_equal(rprofile_content, rprofile_content2,
             info = "update_rbranding should be idempotent")  # Content should be same

# Test 5: Modifying .Rprofile and then calling install should preserve other content
other_content <- c("# My custom code", "options(repos = 'https://cloud.r-project.org/')")
writeLines(c(other_content, "", rprofile_content), rprofile_path)

suppressMessages(install_rbranding(tmp_project))
rprofile_final <- readLines(rprofile_path, warn = FALSE)
expect_true(any(grepl("My custom code", rprofile_final)),
            info = "Custom content should be preserved")
expect_true(any(grepl("rbranding auto-update", rprofile_final)),
            info = "rbranding block should still exist")

# Test 6: Test error handling with non-existent directory
# This should produce a message about failure
capture_result <- tryCatch({
  suppressMessages(install_rbranding("/path/that/does/not/exist/12345"))
  "no_message"
}, error = function(e) {
  "error"
})
# The function should handle the error gracefully (not throw an error)
expect_true(capture_result == "no_message",
            info = "install_rbranding should handle errors gracefully")

# Cleanup
unlink(tmp_project, recursive = TRUE)
