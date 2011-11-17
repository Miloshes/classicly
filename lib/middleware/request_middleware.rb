class RequestMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    
    # web_api queries
    if request.request_method == "POST" && request.url.include?("web_api")
      
      # force SSL
      # if env['HTTPS'] == 'on' || env['HTTP_X_FORWARDED_PROTO'] == 'https'
      #   @app.call(env)
      # else
      #   req     = Rack::Request.new(env)
      #   new_url = req.url.clone
      #   
      #   # change HTTP to HTTPS
      #   new_url.gsub!(/^http:/, "https:")
      #   # change //classicly.com to //secure.classicly.com
      #   new_url.gsub!(/\/\/classicly\.com/, "//secure.classicly.com")
      #   
      #   # TODO: make sure this redirect uses a POST method too
      #   [301, { "Location" => new_url }, []]
      # end

      # not forcing SSL, just after all our apps are updated to use the secure channel
      @app.call(env)

    else
      
      # not web_api queries - URL should start with www
      if !request.host.starts_with?("www.")
        [301, {"Location" => request.url.sub("//", "//www.")}, self]
      else
        @app.call(env)
      end
      
    end
  end

  def each(&block)
  end

end
