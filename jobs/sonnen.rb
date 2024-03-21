require 'net/http'
require 'json'

require_relative 'chart_repo'

BATTERY_HOSTNAME = '192.168.1.125'

uri = URI('http://' + BATTERY_HOSTNAME + ':8080/api/v1/status')

battery_power_repo = ChartRepo.new()
consumption_repo = ChartRepo.new()
production_repo = ChartRepo.new()
grid_repo = ChartRepo.new()

SCHEDULER.every '2s' do
  begin 
    response = Net::HTTP.get(uri)
    json = JSON.parse(response)

    battery_power_repo.add(json['Pac_total_W'])
    consumption_repo.add(json['Consumption_W'])
    production_repo.add(json['Production_W'])
    grid_repo.add(json['GridFeedIn_W'])

    send_event('charge', { value: json['USOC'] })
    send_event('battery-power-chart', points: battery_power_repo.history, displayed_value: battery_power_repo.history.first['y'])
    send_event('consumption-chart', points: consumption_repo.history, displayed_value: consumption_repo.history.first['y'])
    send_event('grid-chart', points: grid_repo.history, displayed_value: grid_repo.history.first['y'])
    send_event('production-chart', points: production_repo.history, displayed_value: production_repo.history.first['y'])
  rescue StandardError => err
    puts err
  end
end