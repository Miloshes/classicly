class AuthorQuoting < ActiveRecord::Base
  belongs_to :author
  belongs_to :blog_post
end
