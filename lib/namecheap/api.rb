module Namecheap
  class Api
    SANDBOX = 'https://api.sandbox.namecheap.com/xml.response'
    PRODUCTION = 'https://api.namecheap.com/xml.response'
    ENVIRONMENT = defined?(Rails) && Rails.respond_to?(:env) ? Rails.env : (ENV["RACK_ENV"] || 'development')
    ENDPOINT = (ENVIRONMENT == 'production' ? PRODUCTION : SANDBOX)

    def get(command, options = {})
      request 'get', command, options
    end

    def post(command, options = {})
      request 'post', command, options
    end

    def put(command, options = {})
      request 'post', command, options
    end

    def delete(command, options = {})
      request 'post', command, options
    end

    def request(method, command, options = {})
      command = 'namecheap.' + command
      options = init_args.merge(options).merge({:command => command})
      options.camelize_keys!
      
      puts "calling #{command} with #{options.to_s}"
      
      case method
      when 'get'
        ProxyParty.get(ENDPOINT, {:body=>options})
      when 'post'
        ProxyParty.post(ENDPOINT, options)
      when 'put'
        ProxyParty.put(ENDPOINT, options)
      when 'delete'
        ProxyParty.delete(ENDPOINT, options)
      end
    end

    def init_args
      options = {
        :ApiUser  => Namecheap.username,
        :UserName => Namecheap.username,
        :ApiKey   => Namecheap.key,
        :ClientIp => Namecheap.client_ip
      }
    end
  end
end
