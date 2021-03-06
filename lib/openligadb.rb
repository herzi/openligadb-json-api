require 'savon'

class String
  def lower_camelcase
    str = dup
    str.gsub!(/\/(.?)/) { "::#{$1.upcase}" }
    str.gsub!(/(?:_+|-+)([a-z])/) { $1.upcase }
    str.gsub!(/(\A|\s)([A-Z])/) { $1 + $2.downcase }
    str
  end
end

Savon.configure do |config|
  config.log_level = :error      # changing the log level
end

class OpenLigaDB
  def initialize
    @client = Savon::Client.new "http://www.openligadb.de/Webservices/Sportsdata.asmx?wsdl"
  end
  
  def request(action, params)
    action = "get_#{action}".gsub(/id$/, 'iD')
    
    response = @client.request :wsdl, action do
      soap.body = {}
      params.each do |key, value|
        unless key == :action
          key = key.lower_camelcase.gsub(/Id$/, 'ID').gsub(/Id_1$/, 'ID1').gsub(/Id_2$/, 'ID2')
          soap.body[key] = value
        end
      end
    end

    hash = response.to_hash
    hash = hash[hash.keys.first]
    hash.delete :@xmlns
    hash[hash.keys.first] 
  end
  
  private
    
end