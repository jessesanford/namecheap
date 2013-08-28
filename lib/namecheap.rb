require 'httparty'
require 'monkey_patch'
require 'pp'

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/namecheap")
Dir.glob("#{File.dirname(__FILE__)}/namecheap/*.rb") { |lib| require File.basename(lib, '.*') }

module Namecheap

  extend self

  # Sets the Namecheap configuration options. Best used by passing a block.
  #
  # @example Set up configuration options.
  #   Namecheap.configure do |config|
  #     config.key = "apikey"
  #     config.username = "apiuser"
  #     config.client_ip = "127.0.0.1"
  #   end
  # @return [ Config ] The configuration obejct.
  def configure
    block_given? ? yield(Config) : Config
  end
  alias :config :configure
  
  # Take all the public instance methods from the Config singleton and allow
  # them to be accessed through the Namecheap module directly.
  #
  # @example Delegate the configuration methods.
  #   Namecheap.key = 'newkey'
  delegate *(Config.public_instance_methods(false) << { :to => Config })

  attr_accessor :domains, :dns, :ns, :transfers, :ssl, :users, :whois_guard, :proxy_party
  self.domains = Namecheap::Domains.new
  self.dns = Namecheap::Dns.new
  self.ns = Namecheap::Ns.new
  self.transfers = Namecheap::Transfers.new
  self.ssl = Namecheap::Ssl.new
  self.users = Namecheap::Users.new
  self.whois_guard = Namecheap::Whois_Guard.new
  
  class ProxyParty
    include HTTParty
    # Allows setting http proxy information to be used
    #
    #   class Foo
    #     include HTTParty
    #     http_proxy 'http://foo.com', 80, 'user', 'pass'
    #   end
  
    #http_proxy 'localhost', 8888
  
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
  
  self.proxy_party = ProxyParty.new

end
