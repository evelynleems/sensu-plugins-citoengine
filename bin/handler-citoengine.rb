#!/opt/sensu/embedded/bin/ruby

# Copyright 2016 Evelyn Lee.
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.
#
# In order to use this plugin, you must first configure an event ID
# citoengine.
#
# After you configure your eventid, you'll need the eventid from the integration.

require 'sensu-handler'
require 'json'
require 'erubis'

class Citoengine < Sensu::Handler
  option :json_config,
         description: 'Configuration name',
         short: '-j JSONCONFIG',
         long: '--json JSONCONFIG',
         default: 'citoengine'

  def payload_template
    get_setting('payload_template')
  end

  def citoengine_event_id
    get_setting('event_id')
  end

  def citoengine_url
    get_setting('url')
  end

  def citoengine_element
    get_setting('element')
  end

  def citoengine_message_prefix
    get_setting('message_prefix')
  end

  def message_template
    get_setting('template') || get_setting('message_template')
  end

  def proxy_address
    get_setting('proxy_address')
  end

  def proxy_port
    get_setting('proxy_port')
  end

  def proxy_username
    get_setting('proxy_username')
  end

  def proxy_password
    get_setting('proxy_password')
  end

  def incident_key
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def get_setting(name)
    settings[config[:json_config]][name]
  end

  def handle
    post_data(render_payload_template)
  end

  def render_payload_template
    return unless payload_template && File.readable?(payload_template)
    template = File.read(payload_template)
    eruby = Erubis::Eruby.new(template)
    eruby.result(binding)
  end

  def post_data(body)
    uri = URI(citoengine_url)
    http = if proxy_address.nil?
             Net::HTTP.new(uri.host, uri.port)
           else
             Net::HTTP::Proxy(proxy_address, proxy_port, proxy_username, proxy_password).new(uri.host, uri.port)
           end
    http.use_ssl = true

    req = Net::HTTP::Post.new("#{uri.path}")
    body.gsub!(/\n/,'')
    req.body = body
    response = http.request(req)

    verify_response(response)
  end

  def verify_response(response)
    case response
    when Net::HTTPSuccess
      true
    else
      raise response.error!
    end
  end

  def check_status
    @event['check']['status']
  end

  def translate_status
    status = {
      0 => :OK,
      1 => :WARNING,
      2 => :CRITICAL,
      3 => :UNKNOWN
    }
    status[check_status.to_i]
  end
end
