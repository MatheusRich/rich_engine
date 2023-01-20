# frozen_string_literal: true

require "rich_engine"

class BgExample < RichEngine::Game
  using RichEngine::StringColors

  def on_create
    @timer = RichEngine::Timer.new
    @canvas.bg = RichEngine::UI::Textures.solid.blue
    @clouds = 5.times.map { |i| Cloud.new(x: -(i + 1) * 20) }
    @sun = Sun.new
  end

  def on_update(elapsed_time, key)
    quit! if key == :q

    @timer.update(elapsed_time)
    @clouds.each { |cloud|
      cloud.update(elapsed_time)

      if cloud.x > @config[:screen_width]
        @clouds.delete(cloud)
        @clouds << Cloud.new
      end
    }

    @canvas.clear

    @sun.draw(@canvas)
    @clouds.each { _1.draw(@canvas) }

    draw_ground
  end

  def draw_ground
    @canvas.draw_rect(
      x: 0,
      y: @config[:screen_height] - 1,
      width: @config[:screen_width],
      height: 1,
      color: :black
    )
  end
end

class Sun
  attr_accessor :x, :y

  def initialize
    @x = 0
    @y = 0
  end

  def update(elapsed_time)
  end

  def draw(canvas)
    canvas.draw_sprite(sprite, x: @x, y: @y, fg: :yellow)
  end

  def sprite
    <<~SUN
      ████
      ████
    SUN
  end
end

class Cloud
  attr_accessor :x, :y

  def initialize(x: -rand(5..300))
    @x = x
    @y = rand(0..4)
    @color = [:white, :bright_white].sample
    @sprite = cloud_sprites.sample
    @speed = rand(1..10)
  end

  def update(elapsed_time)
    @x += elapsed_time * @speed
  end

  def draw(canvas)
    canvas.draw_sprite(
      @sprite,
      x: @x.round,
      y: @y,
      fg: @color
    )
  end

  def cloud_sprites
    [
      shape1,
      shape2,
      shape3,
      shape4,
      shape5
    ]
  end

  def shape1
    <<~CLOUD
        ██
      ██████
    CLOUD
  end

  def shape2
    <<~CLOUD
       ███ ████
      ██████████
    CLOUD
  end

  def shape3
    <<~CLOUD
       ███
      █████
    CLOUD
  end

  def shape4
    <<~CLOUD
      ███
    CLOUD
  end

  def shape5
    <<~CLOUD
      █████
    CLOUD
  end
end

BgExample.play
