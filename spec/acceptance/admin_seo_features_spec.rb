require 'acceptance/acceptance_helper'

feature 'Admin seo features', %q{
  In order to manage SEO requirements in the application
  As an administrator
  I want to have an interface to modify titles, metadesccriptions, and more
} do

  background :each do
    # Given I am an admin user
    @admin = AdminUser.make!
    # And I log in
    admin_login(@admin)
  end
  
  scenario 'Assigning a default structure for a book\'s metadescription in the admin app' do
    # and I am on the admin seo section
    visit 'admin/admin_seo'
    # When I go to assign the default SEO structure
    click_on 'Set defaults for SEO info'
    # And I select to assign the default structure for a book
    
  end
end
