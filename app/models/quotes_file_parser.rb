class QuotesFileParser
  include Rake::DSL

  attr_accessor :text, :authors, :final_quotes

  def initialize(file_name)
    @file_name = file_name
    @text = ''
    File.open(file_name).each{|line| @text << line }
    set_authors
  end

  def parse_quotes_file_to_array
    @final_quotes = []
    0.upto(@authors.length - 1) do|index|
      final_quotes << quotes_array(index)
    end
    @final_quotes.flatten!(1)
  end
  
  def author_name(index)
    return @authors[index].gsub('-', '')
  end

  def author_quotes(index)
    start = @text.index(@authors[index]) + @authors[index].length
    stop  = index == (@authors.length - 1) ? @text.length : @text.index(@authors[index + 1])
    return @text[start...stop]
  end
  
  def parsed_author_names
    parsed_authors = []
    0.upto(@authors.length - 1) do|index|
      parsed_authors << author_name(index)
    end
    parsed_authors
  end
  
  def quotes_array(index)
    quotes = []
    author_quotes(index).each_line do|line|
      text = line.strip
      quotes << [author_name(index), text ] unless text.length < 4
    end
    quotes
  end
  
  def show_file
    @text.each_line { |line| puts line.chomp }
  end
  
  def total_authors
    @authors.count
  end

  private
  def set_authors
    @authors = @text.scan(/--[\w+\s*]+--/)
  end
end
