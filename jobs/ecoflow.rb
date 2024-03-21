if !ENV['SMASHING_HASS_TOKEN'] || !ENV['SMASHING_HASS_URL']
    puts '*WARNING*: Env vars for home assistant is not set, skipping ecoflow job'
  else
    token = ENV['SMASHING_HASS_TOKEN']
    url = ENV['SMASHING_HASS_URL']

    SCHEDULER.every '30s', first_in: 0 do
      begin  
        info_uri = URI.parse(url + "/api/states/sensor.ecoflow_battery_level")
        info_req = Net::HTTP::Get.new(
          info_uri,
          'Content-Type' => 'application/json',
          'Authorization' => 'Bearer ' + token
        )
        info_res = Net::HTTP.start(info_uri.hostname, info_uri.port) do |http|
          http.request(info_req)
        end
        info_json = JSON.parse(info_res.body)
        charge = info_json['state'].to_i
        send_event('ecoflow-charge', { 
          value: charge,
        })
      rescue => err
        puts err
      end
    end
  end
  