module Namecheap
  class Api

    SANDBOX = 'https://api.sandbox.namecheap.com/xml.response'
    PRODUCTION = 'https://api.namecheap.com/xml.response'
    ENVIRONMENT = defined?(Rails) && Rails.respond_to?(:env) ? Rails.env : (ENV["RACK_ENV"] || 'development')
    REQUIRED_PARAMS = %w(user_name api_key client_ip)
    DEFAULT_OPTIONS = lambda {
      return {
        http_proxyaddr:   Namecheap.config.proxy_host,
        http_proxyport:   Namecheap.config.proxy_port,
        http_proxyuser:   Namecheap.config.proxy_user,
        http_proxypass:   Namecheap.config.proxy_password,
        force_production: Namecheap.config.force_production
      }
    }
    DEFAULT_PARAMS = lambda {
      return {
        api_user:  Namecheap.config.user_name,
        user_name: Namecheap.config.user_name,
        api_key:   Namecheap.config.key,
        client_ip: Namecheap.config.client_ip
      }
    }
    ENDPOINT = lambda {
      return ((ENVIRONMENT == 'production' || DEFAULT_OPTIONS[][:force_production]) ? PRODUCTION : SANDBOX)
    }

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
      query = DEFAULT_PARAMS[].merge(request_params).merge({:command => command})

      REQUIRED_PARAMS.each do |param|
        unless query[param.to_sym]
          raise Namecheap::Config::RequiredOptionMissing,
            "Configuration parameter missing: #{param}, \
            please add it to the Namecheap.configure block"
        end
      end

      query.keys.each do |key|
        query[key.to_s.camelize] = query.delete(key)
      end

      options = DEFAULT_OPTIONS[].merge(request_options).merge({ :query => query})

      case method
      when 'get'
        HTTParty.get(ENDPOINT[], options)
      when 'post'
        HTTParty.post(ENDPOINT[], options)
      when 'put'
        HTTParty.put(ENDPOINT[], options)
      when 'delete'
        HTTParty.delete(ENDPOINT[], options)
      end
    end
  end
end
