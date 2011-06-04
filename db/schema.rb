# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110604213447) do

  create_table "admin_users", :force => true do |t|
    t.string   "name",                              :null => false
    t.string   "email",                             :null => false
    t.string   "crypted_password",                  :null => false
    t.string   "password_salt",                     :null => false
    t.string   "persistence_token",                 :null => false
    t.integer  "login_count",        :default => 0, :null => false
    t.integer  "failed_login_count", :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email"

  create_table "alternatives", :force => true do |t|
    t.integer "experiment_id"
    t.string  "content"
    t.string  "lookup",        :limit => 32
    t.integer "weight",                      :default => 1
    t.integer "participants",                :default => 0
    t.integer "conversions",                 :default => 0
  end

  add_index "alternatives", ["experiment_id"], :name => "index_alternatives_on_experiment_id"
  add_index "alternatives", ["lookup"], :name => "index_alternatives_on_lookup"

  create_table "audiobook_chapters", :force => true do |t|
    t.integer "audiobook_id"
    t.string  "title"
    t.integer "duration"
    t.string  "download_link"
    t.integer "audiobook_narrator_id"
  end

  create_table "audiobook_narrators", :force => true do |t|
    t.string "name"
  end

  create_table "audiobooks", :force => true do |t|
    t.string  "title"
    t.integer "author_id"
    t.boolean "blessed",          :default => false, :null => false
    t.integer "custom_cover_id"
    t.string  "pretty_title"
    t.string  "cached_slug"
    t.text    "description"
    t.integer "avg_rating",       :default => 0,     :null => false
    t.integer "downloaded_count", :default => 0
  end

  create_table "authors", :force => true do |t|
    t.string "name"
    t.string "cached_slug"
  end

  add_index "authors", ["cached_slug"], :name => "index_authors_on_cached_slug", :unique => true

  create_table "blog_posts", :force => true do |t|
    t.string    "title"
    t.text      "content"
    t.string    "keywords"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "cached_slug"
    t.string    "meta_description"
  end

  create_table "blog_posts_books", :id => false, :force => true do |t|
    t.integer "blog_post_id"
    t.integer "book_id"
  end

  create_table "book_pages", :force => true do |t|
    t.integer "book_id"
    t.integer "page_number"
    t.integer "first_character"
    t.integer "last_character"
    t.text    "content"
    t.boolean "first_line_indent", :default => false, :null => false
    t.boolean "re_render_flag",    :default => false, :null => false
    t.boolean "force_rerender",    :default => false, :null => false
  end

  add_index "book_pages", ["book_id", "page_number"], :name => "book_id_page_number_index_for_book_pages", :unique => true

  create_table "books", :force => true do |t|
    t.text    "title"
    t.integer "author_id"
    t.string  "language"
    t.integer "published"
    t.boolean "blessed",          :default => false, :null => false
    t.integer "custom_cover_id"
    t.text    "description"
    t.string  "pretty_title"
    t.boolean "available",        :default => true
    t.string  "cached_slug"
    t.integer "avg_rating"
    t.integer "downloaded_count", :default => 0
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
    t.string    "cached_slug"
    t.integer   "downloaded_count",             :default => 0
    t.text      "parsed_description"
  end

  create_table "custom_resources", :force => true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "blog_post_id"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer   "priority",   :default => 0
    t.integer   "attempts",   :default => 0
    t.text      "handler"
    t.text      "last_error"
    t.timestamp "run_at"
    t.timestamp "locked_at"
    t.timestamp "failed_at"
    t.string    "locked_by"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "download_formats", :force => true do |t|
    t.integer "book_id"
    t.string  "format"
    t.boolean "legacy",          :default => true
    t.string  "download_status", :default => "never tried"
  end

  create_table "experiments", :force => true do |t|
    t.string    "test_name"
    t.string    "status"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "experiments", ["test_name"], :name => "index_experiments_on_test_name"

  create_table "genres", :force => true do |t|
    t.string "name"
  end

  create_table "incoming_data", :force => true do |t|
    t.text      "json_data"
    t.boolean   "processed",  :default => false, :null => false
    t.timestamp "created_at"
  end

  create_table "logins", :force => true do |t|
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "first_name"
    t.string    "last_name"
    t.string    "location_city"
    t.string    "location_country"
    t.string    "email"
    t.string    "fb_connect_id"
    t.boolean   "is_admin",         :default => false
  end

  create_table "reviews", :force => true do |t|
    t.string    "fb_connect_id"
    t.integer   "reviewable_id"
    t.string    "reviewable_type"
    t.text      "content"
    t.integer   "rating"
    t.timestamp "created_at"
    t.integer   "login_id"
  end

  add_index "reviews", ["reviewable_id", "reviewable_type"], :name => "reviewable_id_reviewable_type_index_for_reviews"

  create_table "seo_infos", :force => true do |t|
    t.integer  "infoable_id"
    t.string   "meta_description"
    t.string   "title"
    t.string   "og_title"
    t.string   "og_image"
    t.string   "og_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "infoable_type"
  end

  create_table "seo_slugs", :force => true do |t|
    t.integer "seoable_id"
    t.string  "seoable_type"
    t.string  "slug"
    t.string  "format"
  end

  add_index "seo_slugs", ["slug"], :name => "index_seo_slugs_on_slug"

  create_table "sessions", :force => true do |t|
    t.string    "session_id", :null => false
    t.text      "data"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shortened_urls", :force => true do |t|
    t.text     "url"
    t.datetime "created_at"
    t.datetime "last_hit"
    t.integer  "hit_count",  :default => 0
  end

  create_table "slugs", :force => true do |t|
    t.string    "name"
    t.integer   "sluggable_id"
    t.integer   "sequence",                     :default => 1, :null => false
    t.string    "sluggable_type", :limit => 40
    t.string    "scope"
    t.timestamp "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "table_of_contents_chapters", :force => true do |t|
    t.integer "book_id"
    t.integer "volume_id"
    t.string  "chapter_title"
    t.integer "character_offset"
    t.integer "book_page_id"
  end

  create_table "table_of_contents_volumes", :force => true do |t|
    t.string "title"
  end

  create_table "user_sessions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string    "email",                               :default => "", :null => false
    t.string    "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string    "password_salt",                       :default => "", :null => false
    t.string    "reset_password_token"
    t.string    "remember_token"
    t.timestamp "remember_created_at"
    t.integer   "sign_in_count",                       :default => 0
    t.timestamp "current_sign_in_at"
    t.timestamp "last_sign_in_at"
    t.string    "current_sign_in_ip"
    t.string    "last_sign_in_ip"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
