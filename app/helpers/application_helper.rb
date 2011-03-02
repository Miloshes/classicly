module ApplicationHelper
  def list_element_link(path, text)
    content_tag :li do
      content_tag :a, :href => path do
        text
      end
    end
  end

  def typekit_include_helper
    javascript_include_tag('http://use.typekit.com/idk3svd.js').concat(javascript_tag "try{ Typekit.load();}catch(e){}")
  end
end
