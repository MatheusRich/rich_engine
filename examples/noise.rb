# frozen_string_literal: true

require "rich_engine"

class NoiseExample < RichEngine::Game
  def on_create
    @end_timer = RichEngine::Timer.new
    @change_timer = RichEngine::Timer.every(seconds: 0.1)
  end

  def on_update(elapsed_time, key)
    quit! if key == :q

    @end_timer.update(elapsed_time)
    @change_timer.update(elapsed_time)

    @change_timer.when_ready do
      @canvas.clear
      @canvas.each_coord do |x, y|
        @canvas[x, y] = RichEngine::Chance.of_one_in(2) ? "█" : " "
      end
      @canvas.write_string(elapsed_time, x: 1, y: 1)
    end

    quit! if @end_timer.get > 10
  end
end

NoiseExample.play(width: 80, height: 40)
