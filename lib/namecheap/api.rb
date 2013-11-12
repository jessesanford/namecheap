module Namecheap
  class Api
    
    SANDBOX = 'https://api.sandbox.namecheap.com/xml.response'
    PRODUCTION = 'https://api.namecheap.com/xml.response'
    ENVIRONMENT = defined?(Rails) && Rails.respond_to?(:env) ? Rails.env : (ENV["RACK_ENV"] || 'development')
    ENDPOINT = (ENVIRONMENT == 'production' ? PRODUCTION : SANDBOX)
    
    class ProxyParty
      include HTTParty
      # Allows setting http proxy information to be used
      #
      #   class Foo
      #     include HTTParty
      #     http_proxy 'http://foo.com', 80, 'user', 'pass'
      #   end 
      http_proxy '15.185.123.144', 3128, 'stn', 'passme'
  
      def get(endpoint, options)
        puts "getting #{endpoint} with #{options.to_s}"
        self.class.get(endpoint,{:body=>options})
      end
  
      def post(endpoint, options)
        puts "posting #{endpoint} with #{options.to_s}"
        self.class.post(endpoint,{:body=>options})
      end
  
      def put(endpoint, options)
        puts "putting #{endpoint} with #{options.to_s}"
        self.class.put(endpoint,{:body=>options})
      end
  
      def delete(endpoint, options)
        puts "deleting #{endpoint} with #{options.to_s}"
        self.class.delete(endpoint,{:body=>options})
      end
    end

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
      proxy_party = ProxyParty.new
      command = 'namecheap.' + command
      options = init_args.merge(options).merge({:command => command})
      options.camelize_keys!
      
      puts "calling #{command} with #{options.to_s}"
      
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

    def init_args
      options = {
        :ApiUser  => Namecheap.apiuser,
        :UserName => Namecheap.username,
        :ApiKey   => Namecheap.key,
        :ClientIp => Namecheap.client_ip
      }
    end
  end
end
