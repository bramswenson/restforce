require 'restforce/middleware'

module Restforce
  module Concerns
    module Authentication

      # Public: Force an authentication
      def authenticate!
        raise AuthenticationError, 'No authentication middleware present' unless authentication_middleware
        middleware = authentication_middleware_class.new nil, self, options
        middleware.authenticate!
      end

      # Internal: Determines what middleware will be used based on the options provided
      def authentication_middleware
        if username_password?
          :restforce_password
        elsif oauth_refresh?
          :restforce_token
        end
      end

      def authentication_middleware_class
        authentication_middlewares[authentication_middleware]
      end

      def authentication_middlewares
        {
          :restforce_password => Restforce::Middleware::Authentication::Password,
          :restforce_token    => Restforce::Middleware::Authentication::Token
        }
      end

      # Internal: Returns true if username/password (autonomous) flow should be used for
      # authentication.
      def username_password?
        options[:username] &&
          options[:password] &&
          options[:client_id] &&
          options[:client_secret]
      end

      # Internal: Returns true if oauth token refresh flow should be used for
      # authentication.
      def oauth_refresh?
        options[:refresh_token] &&
          options[:client_id] &&
          options[:client_secret]
      end

    end
  end
end
