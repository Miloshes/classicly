class WwwMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    if !request.host.starts_with?("www.") && !request.url.include?("web_api")
      [301, {"Location" => request.url.sub("//", "//www.")}, self]
    else
      @app.call(env)
    end
  end

  def each(&block)
  end

end
