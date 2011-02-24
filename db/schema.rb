ActiveRecord::Schema.define(:version => 20110224212843) do

  create_table "audiobooks", :force => true do |t|
    t.string  "title"
    t.integer "author_id"
    t.boolean "blessed",         :default => false, :null => false
    t.integer "custom_cover_id"
  end

  create_table "authors", :force => true do |t|
    t.string "name"
  end

  create_table "books", :force => true do |t|
    t.text    "title"
    t.integer "author_id"
    t.string  "language"
    t.integer "published"
    t.boolean "blessed",         :default => false, :null => false
    t.integer "custom_cover_id"
    t.text    "description"
  end

  create_table "books_genres", :id => false, :force => true do |t|
    t.integer "book_id"
    t.integer "genre_id"
  end

  create_table "collection_audiobook_assignments", :force => true do |t|
    t.integer "audiobook_id"
    t.integer "collection_id"
    t.boolean "featured",      :default => false, :null => false
  end

  create_table "collection_book_assignments", :force => true do |t|
    t.integer "book_id"
    t.integer "collection_id"
    t.boolean "featured",      :default => false, :null => false
  end

  create_table "collections", :force => true do |t|
    t.string    "name"
    t.string    "book_type"
    t.string    "collection_type"
    t.string    "paperback_color"
    t.string    "source_type"
    t.text      "description"
    t.text      "source"
    t.boolean   "has_image",                    :default => false, :null => false
    t.boolean   "featured",                     :default => false, :null => false
    t.timestamp "created_at"
    t.string    "author_portrait_file_name"
    t.string    "author_portrait_content_type"
    t.integer   "author_portrait_file_size"
    t.timestamp "author_portrait_updated_at"
    t.integer   "genre_id"
  end

  create_table "genres", :force => true do |t|
    t.string "name"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

end
