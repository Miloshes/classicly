class ShareMessageHandler
  # we have to be able to handle URLs in the model
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers
  include CommonSeoDefaultsMethods
  
  attr_accessor :target_platform, :message_type

  # Possible candidates for twitter book shares:
  # "Reading {{book title}} in @classiclyapp on my iPad. Download the book as {{available formats}} (free!) here: {{book url}}",
  # "Just started reading {{book title}} in @classiclyapp on my iPad. {{book url}}"
  
  MESSAGE_STUBS = {
    # NOTE: assumption here is that the URLs are at the end of the Twitter message
    "twitter" => {
      "book share" => 
        "I'm reading {{book author}}'s {{book title}} right now in @classiclyapp. You can download it {{available formats}} at {{book url}}",
      "highlight share" => 
        "Highlighted {{book title}} in @classiclyapp: {{book highlight}} {{highlight url}}",
      "note share" =>
        "Took a note on {{book title}} in @classiclyapp: \"{{note}}\" {{highlight url}}"
    },
    "facebook" => {
      "book share" => {
        "title"       => "I'm reading {{book title}} by {{book author}}",
        "link"        => "{{book url}}",
        "description" => "I'm reading with Classicly- 23,469 books and it's 100% free. Click the link and you can download {{book title}} for free in {{available formats}}. Here's my highlight:\n\n{{book highlight}}"
      },
      "highlight share" => {
        "title"       => "Found this in {{book title}}:",
        "link"        => "{{highlight url}}",
        "description" => "I'm reading with Classicly- 23,469 books and it's 100% free. Click the link and you can download {{book title}} for free in {{available formats}}. Here's my highlight:\n\n{{book highlight}}"
      }
    }
  }
  
  def initialize
  end

  def get_message_for(target_platform = "twitter", message_type = "book share", params = {})
    raw_message = MESSAGE_STUBS[target_platform][message_type]
    
    return nil if raw_message.blank?
    
    assembled_message = assemble_message_for_twitter(raw_message, message_type, params)
    
    return assembled_message
  end
  
  private
  
  def assemble_message_for_twitter(raw_message, message_type, params)
    if params[:book] && params[:book].is_a?(Fixnum)
      params[:book] = Book.find(params[:book])
    end
    
    if params[:highlight] && params[:book].blank?
      params[:book] = params[:highlight].book
    end
    
    default_url_options[:host] = "www.classicly.com"
    default_url_options[:host] = "classicly-staging.heroku.com" if Rails.env.staging?
    
    params_for_variable_replacement = {
      "book title"        => params[:book].title,
      "book author"       => params[:book].author.name,
      "available formats" => params[:book].pretty_download_formats.join("/"),
      "book url"          => author_book_url(params[:book].author.cached_slug, params[:book].cached_slug),
      "book highlight"    => params[:highlight] ? params[:highlight].content : nil
    }
    
    result = replace_variables(raw_message, params_for_variable_replacement)
    
    if result.length > 120
      result = replace_variables(raw_message, params_for_variable_replacement, {:shorten_by => result.length - 120})
    end
    
    # NOTE: assumption here is that the URLs are at the end of the Twitter message
    # if we want to omit the share URL for twitter
    if params[:twitter_without_url]
      match_result = result.match /(.*)(?:http:\/\/.*)/
      result = match_result[1]
    end
    
    return result
  end
  
  def replace_variables(starting_message, params, options = {})
    result = starting_message.clone
    
    # We need to shorten the message
    if options[:shorten_by]

      # get the variable we can shorten. Starting array is sorted by importance in a descending order.
      variable_to_short_by = ["book highlight", "book title", "book author"].select { |variable|
        !params[variable].blank?
      }.first

      params.each_pair do |variable, value|
        if variable == variable_to_short_by
          value = value[0 ... -(options[:shorten_by] + 3)] + "..."
        end
        Rails.logger.info("!!! replacing: #{variable} with #{value} in #{result}")
        result = result.gsub("{{" + variable + "}}", value) if value
        Rails.logger.info("!!! after: #{result}")
      end

    else
      # Just do straight up variable replacement 
      params.each_pair do |variable, value|
        result.gsub!("{{" + variable + "}}", value) if value
      end
    end
    
    return result
  end
  
end