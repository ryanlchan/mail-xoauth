module Mail
  class XOauthSMTP < XOauth2SMTP
    def initialize(values)
      p 'Mail::XOAuthSMTP has been depreciated; please specify an OAuth version (i.e. XOAuth2SMTP)'
      super
    end
  end
end
