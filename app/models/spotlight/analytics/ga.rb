require 'signet/oauth_2/client'
require 'legato'

module Spotlight
  module Analytics
    ##
    # Google Analytics data provider for the Exhibit dashboard
    class Ga
      extend Legato::Model

      cattr_writer :user, :site

      metrics :sessions, :users, :pageviews

      def self.enabled?
        user && site
      end

      def self.for_exhibit(exhibit)
        path(Spotlight::Engine.routes.url_helpers.exhibit_path(exhibit))
      end

      filter :path, &->(path) { contains(:pagePath, "^#{path}") }

      def self.user(scope = 'https://www.googleapis.com/auth/analytics.readonly')
        @user ||= begin
                    Legato::User.new(oauth_token(scope))
                  rescue => e
                    Rails.logger.info(e)
                    nil
                  end
      end

      def self.site
        @site ||= user.accounts.first.profiles.first { |x| x.web_property_id = Spotlight::Engine.config.ga_web_property_id }
      end

      def self.exhibit_data(exhibit, options)
        context(exhibit).results(site, Spotlight::Engine.config.ga_analytics_options.merge(options)).to_a.first || exhibit_data_unavailable
      end

      def self.exhibit_data_unavailable
        OpenStruct.new(pageviews: 'n/a', users: 'n/a', sessions: 'n/a')
      end

      def self.page_data(exhibit, options)
        options[:sort] ||= '-pageviews'
        query = context(exhibit).results(site, Spotlight::Engine.config.ga_page_analytics_options.merge(options))
        query.dimensions << :page_path
        query.dimensions << :page_title

        query.to_a
      end

      def self.context(exhibit)
        if exhibit.is_a? Spotlight::Exhibit
          for_exhibit(exhibit)
        else
          path(exhibit)
        end
      end

      def self.oauth_token(scope)
        require 'oauth2'

        access_token = auth_client(scope).fetch_access_token!
        OAuth2::AccessToken.new(oauth_client, access_token['access_token'], expires_in: access_token['expires_in'])
      end

      def self.oauth_client
        OAuth2::Client.new('', '', authorize_url: 'https://accounts.google.com/o/oauth2/auth',
                                   token_url: 'https://accounts.google.com/o/oauth2/token')
      end

      def self.signing_key
        @signing_key ||= OpenSSL::PKCS12.new(File.read(Spotlight::Engine.config.ga_pkcs12_key_path), 'notasecret').key
      end

      def self.auth_client(scope)
        Signet::OAuth2::Client.new token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
                                   audience: 'https://accounts.google.com/o/oauth2/token',
                                   scope: scope,
                                   issuer: Spotlight::Engine.config.ga_email,
                                   signing_key: signing_key,
                                   sub: Spotlight::Engine.config.ga_email
      end
    end
  end
end
