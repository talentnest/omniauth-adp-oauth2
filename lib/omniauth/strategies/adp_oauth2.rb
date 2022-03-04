require 'multi_json'
require 'jwt'
require 'omniauth/strategies/oauth2'
require 'uri'

module OmniAuth
  module Strategies
    class AdpOauth2 < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = %w(api openid profile)

      option :name, 'adp_oauth2'
      option :skip_jwt, false
      option :jwt_leeway, 60
      option :authorize_options, %i(response_type client_id redirect_uri scope state)

      option :client_options, {
        :site          => ENV['ADP_AUTH_HOST'] || 'https://accounts.adp.com',
        :authorize_url => '/auth/oauth/v2/authorize',
        :token_url     => '/auth/oauth/v2/token'
      }

      uid do
        raw_info['sub']
      end

      info do
        {
          name: raw_info['name'],
          email: raw_info['email'],
          first_name: raw_info['given_name'],
          last_name: raw_info['family_name'],
          organizationOID: raw_info['organizationOID'],
          associateOID: raw_info['associateOID']
        }
      end

      def raw_info
        @raw_info ||= access_token.get(options[:client_options][:user_info_url]).parsed
      end

      def authorize_params
        super.tap do |params|
          options[:authorize_options].each do |k|
            params[k] = request.params[k.to_s] unless [nil, ''].include?(request.params[k.to_s])
          end

          params[:scope] = DEFAULT_SCOPE.join(' ')
          session['omniauth.state'] = params[:state] if params['state']
        end
      end

      private

      def callback_url
        options[:redirect_uri] || (full_host + script_name + callback_path)
      end
    end
  end
end
