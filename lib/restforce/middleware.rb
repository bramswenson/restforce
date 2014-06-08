module Restforce
  # Base class that all middleware can extend. Provides some convenient helper
  # functions.
  class Middleware < Faraday::Middleware
    autoload :RaiseError,     'restforce/middleware/raise_error'
    autoload :Authentication, 'restforce/middleware/authentication'
    autoload :Authorization,  'restforce/middleware/authorization'
    autoload :InstanceURL,    'restforce/middleware/instance_url'
    autoload :Multipart,      'restforce/middleware/multipart'
    autoload :Mashify,        'restforce/middleware/mashify'
    autoload :Caching,        'restforce/middleware/caching'
    autoload :Logger,         'restforce/middleware/logger'
    autoload :Gzip,           'restforce/middleware/gzip'

    def initialize(app, client, options)
      @app, @client, @options = app, client, options
    end

    # Internal: Proxy to the client.
    def client
      @client
    end

    # Internal: Proxy to the client's faraday connection.
    def connection
      client.send(:connection)
    end
  end
end

Faraday::Middleware.register_middleware \
  :restforce_raise_error   => lambda { Restforce::Middleware::RaiseError },
  :restforce_password      => lambda { Restforce::Middleware::Authentication::Password },
  :restforce_token         => lambda { Restforce::Middleware::Authentication::Token },
  :restforce_authorization => lambda { Restforce::Middleware::Authorization },
  :restforce_instance_url  => lambda { Restforce::Middleware::InstanceURL },
  :restforce_multipart     => lambda { Restforce::Middleware::Multipart },
  :restforce_mashify       => lambda { Restforce::Middleware::Mashify },
  :restforce_caching       => lambda { Restforce::Middleware::Caching },
  :restforce_logger        => lambda { Restforce::Middleware::Logger },
  :restforce_gzip          => lambda { Restforce::Middleware::Gzip }
