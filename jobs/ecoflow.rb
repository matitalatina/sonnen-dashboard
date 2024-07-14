if !ENV['SMASHING_HASS_TOKEN'] || !ENV['SMASHING_HASS_URL']
    puts '*WARNING*: Env vars for home assistant is not set, skipping ecoflow job'
  else
    token = ENV['SMASHING_HASS_TOKEN']
    hass_url = ENV['SMASHING_HASS_URL']
    data_fetch = [
      ['ecoflow_battery_level', 'ecoflow-charge', nil],
      ['ecoflow_total_in_power', 'ecoflow-power-in', ChartRepo.new()],
      ['ecoflow_total_out_power', 'ecoflow-power-out', ChartRepo.new()],
    ]

    SCHEDULER.every '10s', first_in: 0 do
      begin
        data_fetch.each do |entity, event, chart|
          value = fetch_from_hass(entity, token, hass_url).to_i
          if not chart
            send_event(event, { 
              value: value,
            })
          else
            chart.add(value)
            send_event(event, {
              points: chart.history,
              displayed_value: chart.history.first['y']
            })
          end
        rescue => err
          puts err
        end
      end
    end
  end
  
def fetch_from_hass(entity, token, hass_url)
  info_uri = URI.parse(hass_url + "/api/states/sensor.#{entity}")
  info_req = Net::HTTP::Get.new(
    info_uri,
    'Content-Type' => 'application/json',
    'Authorization' => 'Bearer ' + token
  )
  info_res = Net::HTTP.start(info_uri.hostname, info_uri.port) do |http|
    http.request(info_req)
  end
  info_json = JSON.parse(info_res.body)
  value = info_json['state']
  return value
end