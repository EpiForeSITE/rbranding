





remote_file = "https://raw.githubusercontent.com/EpiForeSITE/branding-package/refs/heads/main/_brand.yml"
local_file = "_brand.yml"


tempfile_name = tempfile()
# add exception handling if the download fails
tryCatch(
  {
    download.file(
      remote_file,
      destfile = tempfile_name)
  },
  error = function(e) {
    print(paste("Error downloading file:", e))
  }
)

download.file(
            remote_file,
            destfile = tempfile_name)
temp_hash = tools::md5sum(tempfile_name)
local_hash = tools::md5sum(local_file)


print(paste("local hash equals remote hash: ", (local_hash == temp_hash)))
# prompt user to overwrite if the hashes are not equal.
# add exception handling is the file is not found

if (local_hash != temp_hash) {
  print("The local file is different from the remote file.")
  print("do you want to overwrite it? (y/n)")
  answer <- readline()
  if (answer == "y") {
    file.copy(tempfile_name, "_brand.yml", overwrite = TRUE)
    print("File overwritten.")
  } else {
    print("File not overwritten.")
  }
} else {
  print("The local file is the same as the remote file. No action taken.")
}


