# frozen_string_literal: true

require "rich_engine"

class TimerExample < RichEngine::Game
  def on_create
    @timer = RichEngine::Timer.new
    @canvas.bg = "·"
  end

  def on_update(elapsed_time, key)
    quite! if key == :q

    @timer.update(elapsed_time)
    @canvas.clear
    @canvas.write_string("Elapsed: #{@timer.get.round(1)}s", x: 1, y: 1)


    quit! if @timer.get > 10
  end
end

TimerExample.play
