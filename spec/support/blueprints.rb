require 'machinist/active_record'

lorem_ipsum = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras eu molestie diam. Ut faucibus sodales ligula vitae vulputate. Maecenas a risus tortor, in accumsan massa. Nulla ut dolor non dolor consectetur posuere vel nec nisi. Quisque non eros justo. Morbi tellus mi, bibendum vel convallis in, dictum id tellus. In ut metus magna. Quisque massa mi, ullamcorper sed gravida sit amet, dictum ut libero. Nulla nec placerat mi. Quisque nisl risus, feugiat at accumsan ac, rutrum non justo. Nam justo massa, egestas et eleifend ac, rhoncus at lacus. Aliquam vulputate tincidunt sapien et venenatis. Etiam enim sem, molestie at porta et, porta tincidunt tortor. Donec dapibus eleifend varius. Curabitur convallis ultricies odio ac convallis. Quisque vel est id enim iaculis condimentum in quis diam. Fusce non lacus id nisi condimentum bibendum. Quisque erat augue, suscipit a suscipit pharetra, sagittis id nibh. Aliquam dapibus nisl nec quam lacinia aliquam imperdiet a elit. Maecenas sagittis placerat elit ut bibendum.'

# Add your blueprints here.
#
# e.g.
#   Post.blueprint do
#     title { "Post #{sn}" }
#     body  { "Lorem ipsum..." }
#   end

AdminUser.blueprint do
  name {"admin#{sn}"}
  email {"mail_admin#{sn}@hotmail.com"}
  password {'mypassword'}
  password_confirmation{'mypassword'}
end

Audiobook.blueprint do
  author
  avg_rating {5}
  blessed {false}
  description {lorem_ipsum}
  pretty_title{"the audiobook_#{sn}"}
  title {"audiobook_#{sn}, the"}
end

Author.blueprint do
  name {"author_#{sn}"}
end

BlogPost.blueprint do
  title{"blogpost_#{sn}"}
  content{lorem_ipsum}
  meta_description{"metadescription for blogpost_#{sn}"}
end

Book.blueprint do
  author
  avg_rating {1}
  blessed {false}
  description {"Lorem ipsum dolorem ..."}
  downloaded_count {0}
  language {"language#{sn}"}
  pretty_title{"the book_#{sn}"}
  title {"book_#{sn}, the"}
  is_rendered_for_online_reading{false}
end

Collection.blueprint do
  book_type {'book'}
  collection_type {'author'}
  description {lorem_ipsum}
  downloaded_count {0}
  name {"Collection-#{sn}"}
  source {"SELECT * FROM 'books' WHERE (author like '%#{name}%')"}
  source_type {'SQL'}
  books(3)
end

Collection.blueprint(:with_10_books) do
  books(10)
end

Collection.blueprint(:audiobooks) do
  book_type {'audiobook'}
  audiobooks(10)
end

Collection.blueprint(:audiobook_collection_with_ten_audiobooks) do
  collection_type{'collection'}
  book_type {'audiobook'}
  audiobooks(10)
end

Collection.blueprint(:audiobook_author_collection_with_ten_audiobooks) do
  collection_type{'author'}
  book_type {'audiobook'}
  audiobooks(10)
end

Collection.blueprint(:audiohummies) do
  collection_type{'collection'}
  book_type {'audiobook'}
  name{'Hummies'}
  audiobooks(2)
end

Collection.blueprint(:hummies) do
  collection_type{'collection'}
  book_type {'book'}
  name{'Hummies'}
  books(2)
end
DownloadFormat.blueprint do
  legacy{true}
  download_status{"downloaded"}
end

SeoDefault.blueprint do
  object_type{Book}
end

SeoInfo.blueprint do
  infoable_type{'SeoSlug'}
end

SeoSlug.blueprint do
  seoable_type {"Collection"}
end