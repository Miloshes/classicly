module LibrarySessionHandler
  protected

    def current_library
      @current_library ||= fetch_library_for_current_user
    end

    def current_library=(new_library)
      if new_library
        session[:library_id] = new_library.id
        @current_library = new_library
      else
        session[:library_id] = nil
        @current_library = nil
      end
    end

    # Inclusion hook to make #current_library available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_library
    end

    def fetch_library_for_current_user
      if session[:library_id]
        self.current_library = Library.find_by_id(session[:library_id])
      else
        new_session_library  = Library.create(:unregistered => true, :last_accessed => Time.now)
        self.current_library = new_session_library
      end
    end

end
