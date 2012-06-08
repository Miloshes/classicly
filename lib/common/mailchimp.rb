class MailChimp
  
  def initialize(list_id = nil)
    @api = Hominid::API.new APP_CONFIG['mailchimp'][Rails.env]['api_key'], secure: true
    @list_id = list_id || APP_CONFIG['mailchimp'][Rails.env]['list_id']
  end
  
  def batch(action = :subscribe, &block)
    raise 'MC: no block given' unless block_given?
    logins_arel = block.call
    raise "MC: captured block is not an Array/AR::Relation or does not contains Logins (#{logins.class})" unless [Array, ActiveRecord::Relation].include?(logins_arel.class) and logins_arel.first.is_a?(Login)
    logins_arel.find_in_batches(batch_size: 15) do |logins|
      data_array = case action.to_s
      when 'subscribe'
        logins.map {|login| {'EMAIL' => login.email, 'EMAIL_TYPE' => 'html', 'FNAME' => login.first_name, 'LNAME'=> login.last_name} }
      when 'unsubscribe'
        logins.map {|login| login.email }  
      else
        raise "MC: #{action} is not valid. Use :subscribe or :unsubscribe!"
      end

      response = nil
      query do |api|
        response = if action.to_s == 'subscribe'
          api.list_batch_subscribe @list_id, data_array, false, true, false # double opt-in, update if exists, replace interests
        else
          api.list_batch_unsubscribe @list_id, data_array, false, false, false # delete instead of unsub, send goodbye, notify admin 
        end
        puts Rails.logger.info("MC: list_batch_#{action} response: #{response.to_yaml.inspect}")
      end
      if response['error_count'] > 0
        failed_emails = response['errors'].map {|e| e['email'] }
        logins.each {|login| login.update_attribute(:mailchimp_subscribed, true) unless failed_emails.include?(login.email) }
      else
        Login.where(id: logins).update_all(mailchimp_subscribed: true)
      end
    end
  end
  
  def subscribe(login)
    single :subsribe, login
  end
  
  def unsubscribe(login)
    single :unsubsribe, login
  end

  private
  def single(action, login)
    raise "MC: #{login.inspect} is a Login? I don't think so." unless login.is_a?(Login)
    query do |api|
      response = if action.to_s == 'subscribe'
        # list id, email, merges, email format, double opt-in, update if exists, replace interests, send welcome
        api.list_subscribe @list_id, login.email, {'FNAME' => login.first_name, 'LNAME'=> login.last_name}, 'html', false, true, false, false
      else
        api.list_unsubscribe @list_id, login.email, false, false, false
      end
      puts Rails.logger.info("MC: list_#{action} response: #{response.to_yaml.inspect}")
    end
  end

  def query(&block)
    return false unless block_given? 
    retry_count = 0
    begin
      yield @api
    rescue EOFError
      if (retry_count += 1) >= 3
        puts 'MC: establishing connection to MC API failed 3 times in a row.'
        return false
      end
      retry
    end
  end

end
