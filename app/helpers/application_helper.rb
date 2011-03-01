module ApplicationHelper
  def list_element_link(path, text)
    content_tag :li do
      content_tag :a, :href => path do
        text
      end
    end
  end
end
