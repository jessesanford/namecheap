module Namecheap
  class Api

    SANDBOX = 'https://api.sandbox.namecheap.com/xml.response'
    PRODUCTION = 'https://api.namecheap.com/xml.response'
    ENVIRONMENT = defined?(Rails) && Rails.respond_to?(:env) ? Rails.env : (ENV["RACK_ENV"] || 'development')
    DEFAULT_OPTIONS = {
      http_proxyaddr:  Namecheap.config.proxy_host,
      http_proxyport: Namecheap.config.proxy_port,
      http_proxyuser:   Namecheap.config.proxy_user,
      http_proxypass: Namecheap.config.proxy_password,
      force_production: Namecheap.config.force_production
    }
    DEFAULT_PARAMS = {
      api_user:  Namecheap.config.username,
      user_name: Namecheap.config.username,
      api_key:   Namecheap.config.key,
      client_ip: Namecheap.config.client_ip
    }
    REQUIRED_PARAMS = %w(user_name api_key client_ip)
    ENDPOINT = ((ENVIRONMENT == 'production' || DEFAULT_OPTIONS[:force_production]) ? PRODUCTION : SANDBOX)

    def get(command, request_params = {}, request_options = {})
      request 'get', command, request_params, request_options
    end

    def post(command, request_params = {}, request_options = {})
      request 'post', command, request_params, request_options
    end

    def put(command, request_params = {}, request_options = {})
      request 'post', command, request_params, request_options
    end

    def delete(command, request_params = {}, request_options = {})
      request 'post', command, request_params, request_options
    end

    def request(method, command, request_params = {}, request_options = {})
      command = 'namecheap.' + command
      query = DEFAULT_PARAMS.merge(request_params).merge({:command => command})

      query.keys.each do |key|
        query[key.to_s.camelize] = query.delete(key)
      end

      options = DEFAULT_OPTIONS.merge(request_options).merge({ :query => query})

      REQUIRED_PARAMS.each do |param|
        unless options[param]
          raise Namecheap::Config::RequiredOptionMissing,
            "Configuration parameter missing: #{key}, \
            please add it to the Namecheap.configure block"
        end
      end

      case method
      when 'get'
        proxy_party.get(ENDPOINT, options)
      when 'post'
        proxy_party.post(ENDPOINT, options)
      when 'put'
        proxy_party.put(ENDPOINT, options)
      when 'delete'
        proxy_party.delete(ENDPOINT, options)
      end
    end
  end
end
