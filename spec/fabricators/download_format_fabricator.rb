Fabricator(:download_format) do
  format 'pdf'
  download_status 'downloaded'
  book
end
