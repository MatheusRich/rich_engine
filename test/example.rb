# frozen_string_literal: true

require 'rich_engine'

class TimerExample < RichEngine::Game
  def on_create
    @timer = RichEngine::Timer.new
    @canvas.bg = '·'
  end

  def on_update(elapsed_time, key)
    game_over = key == :q

    @timer.update(elapsed_time)
    @canvas.clear
    @canvas.write_string("Elapsed: #{@timer.get.round(1)}s", x: 1, y: 1)
    game_over = true if @timer.get > 10
    @io.write(@canvas.canvas)

    !game_over
  end
end

TimerExample.play
