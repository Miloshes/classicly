class MailChimp
  
  def initialize(list_id = nil)
    @api = Hominid::API.new APP_CONFIG['mailchimp']['api_key'], secure: true
    @list_id = list_id || APP_CONFIG['mailchimp']['list_id']
  end
  
  def batch(action = :subscribe, &block)
    raise 'MC: no block given' unless block_given?
    logins = block.call
    raise "MC: captured block is not an array/AR::Relation or does not contains Logins (#{logins.class})" unless [Array, ActiveRecord::Relation].include?(logins.class) and logins.first.is_a?(Login) 
    data_array = case action.to_s
      when 'subscribe'
        logins.map {|login| {'EMAIL' => login.email, 'EMAIL_TYPE' => 'html', 'FNAME' => login.first_name, 'LNAME'=> login.last_name} }
      when 'unsubscribe'
        logins.map {|login| login.email }  
      else
        raise "MC: #{action} is not valid. Use :subscribe or :unsubscribe!"
    end
    count, start, range = logins.count, 0, 15
    while (data_slice = data_array[start, range])
      puts "Total: #{count},  current range: #{start} - #{start + range}"
      query do |api|
        response = if action.to_s == 'subscribe'
          api.list_batch_subscribe @list_id, data_slice, false, true, false # double opt-in, update if exists, replace interests
        else
          api.list_batch_unsubscribe @list_id, data_slice, false, false, false # delete instead of unsub, send goodbye, notify admin 
        end
        puts Rails.logger.info("MC: list_batch_#{action} response: #{response.to_yaml.inspect}")
      end
      start += range
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
