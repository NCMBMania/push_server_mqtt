require 'mqtt'
require 'uri'
require 'ncmb'

# Create a hash with the connection parameters from the URL
uri = URI.parse ENV['CLOUDMQTT_URL'] || 'mqtt://localhost:1883'
conn_opts = {
  remote_host: uri.host,
  remote_port: uri.port,
  username: uri.user,
  password: uri.password,
}

MQTT::Client.connect(conn_opts) do |c|
  NCMB.initialize application_key: ENV['APPLICATION_KEY'] || "",  client_key: ENV['CLIENT_KEY'] || ""
  loop do
    # The block will be called when you messages arrive to the topic
    c.get(ENV['TOPIC']) do |topic, message|
      @push = NCMB::Push.new
      @push.immediateDeliveryFlag = true
      @push.target = ['ios']
      @push.message = message.force_encoding('utf-8')
      @push.deliveryExpirationTime = "3 day"
      @push.save
    end
  end
end
