module Mail
  class XOauthIMAP < XOauth2IMAP
    def initialize(values)
      p 'Mail::XOAuthIMAP has been depreciated; please specify an OAuth version (i.e. XOAuth2IMAP)'
      super
    end
  end
end
