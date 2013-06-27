module Mail
  class XOauth1SMTP < SMTP
    class MissingAuthInfo < KeyError ; end

    ##
    # Initialize a new connection using OAuth1
    # @param values [Hash] the initialization values
    # @option values [String] :address the email address to login as
    # @option values [String] :consumer_key your consumer key
    # @option values [String] :consumer_secret your consumer secret
    # @option values [String] :token your OAuth 1.0a token
    # @option values [String] :secret your OAuth 1.0a secret
    # @option values [Boolean] :two_legged set to true if using two-legged OAuth
    def initialize(values)
      fail MissingAuthInfo unless values[:address]
      fail MissingAuthInfo if values[:two_legged] && values[:consumer_key].blank? && values[:consumer_secret].blank?
      fail MissingAuthInfo if !values[:two_legged] && values[:token].blank? && values[:secret].blank?
      super values
    end

    def deliver!(mail)
      smtp_from, smtp_to, message = check_delivery_params(mail)

      secret = { consumer_key: settings.fetch(:consumer_key),
                 consumer_secret: settings.fetch(:consumer_secret) }
      if settings.fetch(:two_legged)
        secret.merge two_legged: true
      else
        secret.merge token: settings.fetch(:token), secret: settings.fetch(:secret)
      end

      smtp = Net::SMTP.new('smtp.gmail.com', 587)
      smtp.enable_starttls_auto
      smtp.start('gmail.com', settings.fetch(:address), secret, :xoauth) do |connection|
        response = connection.sendmail(message, smtp_from, smtp_to)
      end

      if settings[:return_response]
        response
      else
        self
      end
    end
  end
end
