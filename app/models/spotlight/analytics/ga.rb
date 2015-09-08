module Spotlight
  module Analytics
    ##
    # Google Analytics data provider for the curation dashboard
    class Ga
      require 'legato'

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

        OAuth2::AccessToken.new(oauth_client, api_client(scope).authorization.access_token, expires_in: 1.hour)
      end

      def self.oauth_client
        OAuth2::Client.new('', '', authorize_url: 'https://accounts.google.com/o/oauth2/auth',
                                   token_url: 'https://accounts.google.com/o/oauth2/token')
      end

      def self.service_account(scope)
        @service_account ||= begin
          oauth_key = Google::APIClient::PKCS12.load_key(Spotlight::Engine.config.ga_pkcs12_key_path, 'notasecret')
          Google::APIClient::JWTAsserter.new(Spotlight::Engine.config.ga_email, scope, oauth_key)
        end
      end

      def self.api_client(scope)
        require 'google/api_client'
        client = Google::APIClient.new(
          application_name: 'spotlight',
          application_version: Spotlight::VERSION
        )
        client.authorization = service_account(scope).authorize
        client
      end
    end
  end
end
