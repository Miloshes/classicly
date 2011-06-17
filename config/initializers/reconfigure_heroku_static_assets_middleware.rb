module Heroku
  
  class StaticAssetsMiddleware
    def cache_static_asset(reply)
      return reply unless can_cache?(reply)
      
      status, headers, response = reply
      
      # that's the only change, set the cache expiration to 1 year vs 12 hours 
      headers['Cache-Control'] = 'public, max-age=31556926'
      
      build_new_reply(status, headers, response)
    end
  end
  
end