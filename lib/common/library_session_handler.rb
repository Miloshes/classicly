module LibrarySessionHandler
  protected

    def current_library
      @current_library ||= fetch_library_for_current_user
    end

    def current_library=(new_library)
      if new_library
        session[:library] = new_library
        @current_library = new_library
      else
        session[:library] = nil
        @current_library = nil
      end
    end

    # Inclusion hook to make #current_library available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_library
    end

    def fetch_library_for_current_user
      # if the user is logged in, get his library
      if current_login
        self.current_library = current_login.library
      else
      # otherwise we keep a library object in the session
        self.current_library = Library.new
      end
    end

end
