Fabricator(:seo_slug) do
  format "pdf"
  seoable(:fabricator => :book)
end
