require 'restforce/middleware'

module Restforce
  module Concerns
    module Connection

      # Public: The Faraday::Builder instance used for the middleware stack. This
      # can be used to insert an custom middleware.
      #
      # Examples
      #
      #   # Add the instrumentation middleware for Rails.
      #   client.middleware.use FaradayMiddleware::Instrumentation
      #
      # Returns the Faraday::Builder for the Faraday connection.
      def middleware
        connection.builder
      end
      alias_method :builder, :middleware

    private

      # Internal: Internal faraday connection where all requests go through
      def connection
        @connection ||= Faraday.new(options[:instance_url], connection_options) do |conn|
          # Handles multipart file uploads for blobs.
          conn.use      :restforce_multipart
          # Converts the request into JSON.
          conn.request  :json

          # Handles reauthentication for 403 responses.
          conn.use      authentication_middleware, self, options if authentication_middleware
          # Sets the oauth token in the headers.
          conn.use      :restforce_authorization, self, options
          # Ensures the instance url is set.
          conn.use      :restforce_instance_url, self, options

          # Follows 30x redirects.
          conn.response :follow_redirects
          # Parses returned JSON response into a hash.
          conn.response :json, :content_type => /\bjson$/

          # Parses JSON into Hashie::Mash structures.
          conn.use      :restforce_mashify, self, options if mashify?
          # Caches GET requests.
          conn.use      :restforce_caching, cache, options if cache
          # Raises errors for 40x responses.
          conn.use      :restforce_raise_error
          # Log request/responses
          conn.use      :restforce_logger, Restforce.configuration.logger, options if Restforce.log?
          # Compress/Decompress the request/response
          conn.use      :restforce_gzip, self, options

          conn.adapter  adapter
        end
      end

      def adapter
        options[:adapter]
      end

      # Internal: Faraday Connection options
      def connection_options
        { :request => {
            :timeout => options[:timeout],
            :open_timeout => options[:timeout] },
          :proxy => options[:proxy_uri]
        }
      end

      # Internal: Returns true if Restforce.configuration.mashify is truthy
      def mashify?
        !(options[:mashify] === false)
      end

    end
  end
end
