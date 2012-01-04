module LoggerHelper

  def debug(text)
    Rails.logger.info("\n -- [DEBUG] #{text.to_s}\n")
  end

end