module HelperMethods
  # Put helper methods you need to be available in all acceptance specs here.
  def collection_slug(url_str)
    fragments = url_str.split('/').last
  end
  
  def create_blog_post_with_text(text, title='The Blog Post')
    visit admin_blog_posts_path
    click_on 'New entry'
    fill_in 'blog_post_title', :with => title
    fill_in 'blog_post_content', :with => text
    fill_in 'blog_post_meta_description', :with => 'This is an awesome post. Check it out'
    click_on 'blog_post_submit'
  end
  
  def admin_login(user)
    visit "/admin"
    fill_in "admin_user_session_email", :with => user.email
    fill_in "admin_user_session_password", :with => user.password
    click_on 'admin_user_session_submit'
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance