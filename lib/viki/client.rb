require 'httparty'
require 'viki/api_object'
require 'viki/request'

module Viki
  class Client
    Dir[File.expand_path('../client/*.rb', __FILE__)].each { |f| require f }

    def initialize(client_id, client_secret)
      @client_id = client_id
      @client_secret = client_secret
      @access_token = auth_request(client_id, client_secret)
    end

    attr_reader :access_token

    include Viki::Request

    def get
      host = "http://www.viki.com/api/v3/"
      path = ""
      params = { access_token: self.access_token }

      #puts @calls
      @calls.each do |c|
        path += "#{c.keys[0]}/"
        next if c.values.empty?

        if c.values[0].length == 1
          if c.values[0][0].is_a?(Hash)
            params.merge!(c.values[0][0])
          else
            path += "#{c.values[0][0]}/"
          end

        elsif c.values[0].length == 2
          path += "#{c.values[0][0]}/"
          params.merge!(c.values[0][1])
        end

      end
      response = HTTParty.get(host + path.chop + ".json", :query => params)
      puts response.header
      APIObject.new(response.body)
    end

    private

    def method_missing(name, *args, &block)
      @calls ||= []
      @calls.push({ name => args })
      self
    end


  end
end

#pure json
#api object
#list of api objects


#response.count
#=> 43
#response.next
#=> <APIObject>
#response.content
#=> <Hash>
# b = response.content
