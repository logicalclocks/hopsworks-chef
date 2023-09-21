ruby_block 'featurestore reindex' do
  block do
    require 'net/https'
    require 'http-cookie'
    require 'json'
    require 'securerandom'

    hopsworks_fqdn = consul_helper.get_service_fqdn("hopsworks.glassfish")
    _, hopsworks_port = consul_helper.get_service("glassfish", ["http", "hopsworks"])
    if hopsworks_port.nil? || hopsworks_fqdn.nil?
      raise "Could not get Hopsworks faqdn/port from local Consul agent. Verify Hopsworks is running with service name: glassfish and tags: [http, hopsworks]"
    end

    hopsworks_endpoint = "https://#{hopsworks_fqdn}:#{hopsworks_port}"
    url = URI.parse("#{hopsworks_endpoint}/hopsworks-api/api/auth/service")
    reindex_url = URI.parse("#{hopsworks_endpoint}/hopsworks-api/api/admin/search/featurestore/reindex")

    params =  {
      :email => node["kagent"]["dashboard"]["user"] ,
      :password => node["kagent"]["dashboard"]["password"]
    }

    http = Net::HTTP.new(url.host, url.port)
    http.read_timeout = 120
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    jar = ::HTTP::CookieJar.new

    http.start do |connection|

      request = Net::HTTP::Post.new(url)
      request.set_form_data(params, '&')
      response = connection.request(request)

      if( response.is_a?( Net::HTTPSuccess ) )
          # your request was successful
          puts "Hopsworks Admin login successful: -> #{response.body}"

          response.get_fields('Set-Cookie').each do |value|
            jar.parse(value, url)
          end

          request = Net::HTTP::Post.new(reindex_url)
          request['Content-Type'] = "application/json"
          request['Cookie'] = ::HTTP::Cookie.cookie_value(jar.cookies(reindex_url))
          request['Authorization'] = response['Authorization']
          response = connection.request(request)

          if ( response.is_a? (Net::HTTPSuccess))
            puts "Hopsworks Reindex - triggered"
          else
            puts response.body
            raise "Hopsworks Reindex - failed: #{response.uri}"
          end
      else
          puts response.body
          raise "Hopsworks Reindex - failed"
      end
    end
  end
  only_if { node['elastic']['featurestore']['reindex'] == "true" }
end