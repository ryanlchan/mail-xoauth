module Mail
  class XOauth1IMAP < IMAP
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

    def start(config=Mail::Configuration.instance, &block)
      raise ArgumentError.new("Mail::Retrievable#imap_start takes a block") unless block_given?

      secret = { consumer_key: settings.fetch(:consumer_key),
                 consumer_secret: settings.fetch(:consumer_secret) }
      if settings.fetch(:two_legged)
        secret.merge two_legged: true
      else
        secret.merge token: settings.fetch(:token), secret: settings.fetch(:secret)
      end

      imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
      imap.authenticate 'XOAUTH', settings.fetch(:address), secret

      yield imap
    ensure
      if defined?(imap) && imap && !imap.disconnected?
        imap.disconnect
      end
    end
  end
end
