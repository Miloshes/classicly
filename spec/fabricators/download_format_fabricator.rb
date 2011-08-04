Fabricator(:download_format) do
  book  

  download_status "downloaded"
  # NOTE: format "pdf" didn't work
  after_build { |df| df.format = "pdf" }
end
