class RequestMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    
    # web_api queries
    if request.request_method == "POST" && request.url.include?("web_api")
      
      # force SSL
      if env['HTTPS'] == 'on' || env['HTTP_X_FORWARDED_PROTO'] == 'https'
        @app.call(env)
      else
        req = Rack::Request.new(env)
        [301, { "Location" => req.url.gsub(/^http:/, "https:") }, []]
      end

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
