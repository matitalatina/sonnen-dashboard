CHART_HISTORY_COUNT = 150
CHART_SKIP_NUMBER = 10

class ChartRepo

  def initialize()
    @history = []
    @counter = 0
  end

  def add(value)
    @history.pop if @counter != 0
    @history << { 'x' => DateTime.now.to_time.to_i, 'y' => value }
    @history = @history.last(CHART_HISTORY_COUNT)

    @counter += 1
    @counter %= CHART_SKIP_NUMBER
  end

  attr_accessor :history, :counter
end