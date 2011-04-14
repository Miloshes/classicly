class AddPrettyTitleToAudioBooks < ActiveRecord::Migration
  def self.up
    add_column :audiobooks, :pretty_title, :string

    converter = Iconv.new('UTF-8//IGNORE', 'UTF-8')

    Audiobook.all.each do |audio_book|
      # fixing some issues with the titles
      fixed_title     = audio_book.title.gsub("\n\n", " - ")
      # setting up variables
      pretty_title    = fixed_title
      lowercase_title = fixed_title.downcase

      if lowercase_title[-5, 5] == ', the'
        pretty_title = "The " + fixed_title[0...-5]
      elsif lowercase_title[-3, 3] == ', a'
        pretty_title = "A " + fixed_title[0...-3]
      elsif lowercase_title[-4, 4] == ', an'
        pretty_title = "An " + fixed_title[0...-4]
      end

      # cut it to comply PostgreSQL limit
      pretty_title = pretty_title[0,255]
      # convert to fix "incomplete multibyte character" errors on PostgreSQL
      pretty_title = converter.iconv(pretty_title)

      audio_book.title        = fixed_title
      audio_book.pretty_title = pretty_title
      audio_book.save
    end
  end

  def self.down
    remove_column :audiobooks, :pretty_title
  end
end
