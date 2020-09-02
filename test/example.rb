# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'rich_engine'

class MyGame < RichEngine::Base
  def on_create
    @timer = RichEngine::Timer.new
  end

  def on_update(elapsed_time, key)
    game_over = key == :q

    @timer.update(elapsed_time)
    write_string("Elapsed: #{@timer.get.round(1)}s", x: 1, y: 1)
    game_over = true if @timer.get > 10

    !game_over
  end
end

MyGame.play
