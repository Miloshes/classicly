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
  
  def fb_open_graph_metadata(config = {})
    content_tag(:meta, nil, {:property => "og:title", :content => "Classicly"}) +
    content_tag(:meta, nil, {:property => "og:type", :content => "website"}) +
    content_tag(:meta, nil, {:property => "og:url", :content => config[:url] || "http://www.classicly.com"}) +
    content_tag(:meta, nil, {:property => "og:image", :content => "http://www.classicly.com/images/logo.png"}) +
    content_tag(:meta, nil, {:property => "og:site_name", :content => "Classicly"}) +
    content_tag(:meta, nil, {:property => "fb:app_id", :content => "191005167590330"}) +
    content_tag(:meta, nil, {:property => "og:description", :content => config[:description] || "Classicly gives you free books for your laptop,  Kindle, Nook, iPad, or iPhone. Just hit download! From Shakespeare to F. Scott Fitzgerald we have all the classics available with a click, browsable with beautiful covers, great descriptions, and hand-picked collections"})
  end
end
