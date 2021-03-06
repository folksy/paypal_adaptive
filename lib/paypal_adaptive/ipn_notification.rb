require 'net/http'
require 'net/https'
require 'json'

module PaypalAdaptive
  class IpnNotification
    
    def initialize(env=nil)
      config = PaypalAdaptive.config(env)
      @paypal_base_url = config.paypal_base_url
      @ssl_cert_path = config.ssl_cert_path
      @ssl_cert_file = config.ssl_cert_file
    end
    
    def send_back(data)
      data = "cmd=_notify-validate&#{data}"
      url = URI.parse @paypal_base_url
      http = Net::HTTP.new(url.host, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.ca_path = @ssl_cert_path unless @ssl_cert_path.nil?
      http.ca_file = @ssl_cert_file unless @ssl_cert_file.nil?
      http.ca_path = "/etc/ssl/certs" if USE_SSL
      
      path = "#{@paypal_base_url}/cgi-bin/webscr"
      response = http.post(path, data)
      response_data = response.body

      # RAILS_DEFAULT_LOGGER.debug( "**************************************************" )
      # RAILS_DEFAULT_LOGGER.debug( "**************************************************" )
      # RAILS_DEFAULT_LOGGER.debug( "*** HTTP CA Path: #{ http.ca_path.inspect }" )
      # RAILS_DEFAULT_LOGGER.debug( "*** PATH: #{ path }" )
      # RAILS_DEFAULT_LOGGER.debug( "*** DATA: #{ data }" )
      # RAILS_DEFAULT_LOGGER.debug( "*** RESPONSE: #{ response.inspect }" )
      # RAILS_DEFAULT_LOGGER.debug( "*** RESPONSE DATA: #{ response_data.inspect }" )
      # RAILS_DEFAULT_LOGGER.debug( "**************************************************" )
      # RAILS_DEFAULT_LOGGER.debug( "**************************************************" )
      
      @verified = response_data == "VERIFIED"
    end
    
    def verified?
      @verified
    end
    
  end
end
