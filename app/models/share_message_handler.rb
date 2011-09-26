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
      "book share"          => "I'm reading {{book author}}'s {{book title}} right now in @classiclyapp. You can download it {{available formats}} at {{book url}}",
      "highlight share"     => "Highlighted {{book title}} in @classiclyapp: {{book highlight}} {{highlight url}}",
      "note share"          => "Took a note on {{book title}} in @classiclyapp: \"{{note}}\" {{highlight url}}",
      "selected text share" => "Just read this via @classiclyapp: \"{{selected text}}\" {{book url}}"
    },
    "facebook" => {
      "book share" => {
        "title"       => "I'm reading {{book title}} by {{book author}}",
        "link"        => "{{book url}}",
        "description" => "This is a link to {{book title}}. Don't have Free Books for iPad? You can still download the book as {{available formats}} -- free."
      },
      "highlight share" => {
        "title"       => "Found this in {{book title}}",
        "link"        => "{{highlight url}}",
        "description" => "I'm reading with Classicly- 23,469 books and it's 100% free. Click the link and you can download {{book title}} for free in {{available formats}}. Here's my highlight:\n\n{{book highlight}}"
      }
    }
  }
  
  def initialize
  end

  def get_message_for(target_platform = "twitter", message_type = "book share", params = {})
    case target_platform
    # == Twitter
    when "twitter"
      # differentiate sharing highlights from highlights WITH notes (this gets turned into note sharing)
      if message_type == "highlight share" && params[:highlight] && !params[:highlight].origin_comment.blank?
        message_type = "note share"
      end
      
      raw_message = MESSAGE_STUBS[target_platform][message_type]

      return nil if raw_message.blank?
      
      assembled_message = assemble_message_for_twitter(raw_message, message_type, params)
      
      return assembled_message
      
    # == Facebook
    when "facebook"
      raw_messages_hash = MESSAGE_STUBS[target_platform][message_type]
      assembled_message_hash = assemble_message_for_facebook(raw_messages_hash, message_type, params)
      
      return assembled_message_hash
      
    # == backup
    else
      return nil
    end
  end
  
  private
  
  def assemble_message_for_twitter(raw_message, message_type, params)
    params_for_variable_replacement = assemble_params_for_variable_replacement(params)
    
    # do the variable replacement to get the share message
    result = replace_variables(raw_message, params_for_variable_replacement)

    result_without_url = message_without_url(result)

    # shorten if it's necessary
    if result_without_url.length > 120
      result = replace_variables(raw_message, params_for_variable_replacement, {:shorten_by => result_without_url.length - 120})
      result_without_url = message_without_url(result)
    end

    if params[:twitter_without_url]
      return result_without_url
    else
      return result
    end
  end
  
  def assemble_message_for_facebook(raw_messages_hash = {}, message_type, params)
    params_for_variable_replacement = assemble_params_for_variable_replacement(params)
    
    result = {}
    
    # do the variable replacement for each field in the message
    ["title", "link", "description"].each do |field|
      result[field] = replace_variables(raw_messages_hash[field], params_for_variable_replacement)
    end
    
    result["cover_url"] = Book.cover_url(params[:book].id, 3)

    return result
  end
  
  def assemble_params_for_variable_replacement(params)
    if params[:book] && params[:book].is_a?(Fixnum)
      params[:book] = Book.find(params[:book])
    end
    
    if params[:highlight] && params[:book].blank?
      params[:book] = params[:highlight].book
    end
    
    # needed for the book URL
    default_url_options[:host] = "www.classicly.com"
    default_url_options[:host] = "classicly-staging.heroku.com" if Rails.env.staging?
    
    params_for_variable_replacement = {
      "book title"        => params[:book].title,
      "book author"       => params[:book].author.name,
      "available formats" => params[:book].pretty_download_formats.join("/"),
      "book url"          => author_book_url(params[:book].author.cached_slug, params[:book].cached_slug),
      "book highlight"    => params[:highlight] ? params[:highlight].content : nil,
      "highlight url"     => params[:highlight] ? params[:highlight].public_url : nil,
      "note"              => params[:highlight] ? params[:highlight].origin_comment : nil,
      "selected text"     => params[:selected_text] ? params[:selected_text] : nil
    }
    
    return params_for_variable_replacement
  end
  
  def replace_variables(starting_message, params, options = {})
    result = starting_message.clone
    
    # We need to shorten the message
    if options[:shorten_by]

      # get the variable we can shorten. Starting array is sorted by importance in a descending order.
      variable_to_short_by = ["note", "selected text", "book highlight", "book title", "book author"].select { |variable|
        !params[variable].blank?
      }.first

      params.each_pair do |variable, value|
        # "..." the value if this is the variable that needs to be shortened
        value = value[0 ... -(options[:shorten_by] + 3)] + "..." if variable == variable_to_short_by
        
        # replace variable with value
        result = result.gsub("{{" + variable + "}}", value) if value
      end

    else
      # Just do straight up variable replacement 
      params.each_pair do |variable, value|
        result.gsub!("{{" + variable + "}}", value) if value
      end
    end
    
    return result
  end
  
  def message_without_url(full_message)
    # check the share message without the URL at the end, to determine if it's short enough
    # NOTE: assumption here is that the URLs are at the end of the Twitter message
    # if we want to omit the share URL for twitter
    match_result = full_message.match /(.*)(?:http:\/\/.*)/
    if match_result
      return match_result[1]
    else
      return full_message
    end
  end
  
end