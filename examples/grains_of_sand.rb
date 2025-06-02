# frozen_string_literal: true

require "rich_engine"

class GrainsOfSandExample < RichEngine::Game
  using RichEngine::StringColors

  def on_create
    @canvas.bg = RichEngine::UI::Textures.solid.fg(:yellow)
    @world = World.new(
      grains_of_sand: [
        GrainOfSand.new(x: @config[:screen_width] / 2 - rand(-10..10), y: -1),
        GrainOfSand.new(x: @config[:screen_width] / 2, y: -@config[:screen_height] / 2)
      ],
      game_config: @config
    )
  end

  def on_update(elapsed_time, key)
    quit! if key == :q

    @world.update(elapsed_time, key)

    @canvas.clear

    @world.draw(@canvas)
  end
end

class World
  def initialize(grains_of_sand:, game_config:)
    @grains_of_sand = grains_of_sand
    @game_config = game_config
    @tiles = RichEngine::Matrix.new(width: width, height: height, fill_with: :empty)
    @drop_timer = RichEngine::Timer.every(seconds: 0.05)
  end

  def update(elapsed_time, _key)
    @drop_timer.update(elapsed_time)
    @drop_timer.when_ready do
      results = @grains_of_sand.map { |grain_of_sand|
        next :not_moved if locked?(grain_of_sand)

        if fits?(*grain_of_sand.try_move(:down).position)
          grain_of_sand.move_down
          :moved
        elsif fits?(*grain_of_sand.try_move(:down).try_move(:left).position)
          grain_of_sand.move_down.move_left
          :moved
        elsif fits?(*grain_of_sand.try_move(:down).try_move(:right).position)
          grain_of_sand.move_down.move_right
          :moved
        else
          lock_drop(grain_of_sand)
          :not_moved
        end
      }

      if results.none?(:moved)
        raise RichEngine::Game::Exit
      elsif has_available_space?
        @grains_of_sand << GrainOfSand.new(x: (@game_config[:screen_width] / 2) + rand(-20..20), y: 0)
      end
    end
  end

  def draw(canvas)
    @grains_of_sand.each { _1.draw(canvas) }
  end

  private

  def locked?(grain_of_sand)
    @tiles[grain_of_sand.x, grain_of_sand.y] == :filled
  end

  def fits?(x, y)
    x >= 0 && x < width && y < height && @tiles[x, y] != :filled
  end

  def lock_drop(grain_of_sand)
    @tiles[grain_of_sand.x, grain_of_sand.y] = :filled
  end

  def has_available_space?
    @tiles.any? { |tile| tile == :empty }
  end

  def width
    @game_config[:screen_width]
  end

  def height
    @game_config[:screen_height]
  end
end

class GrainOfSand
  using RichEngine::StringColors

  attr_reader :x, :y

  def initialize(x:, y:)
    @x = x
    @y = y
  end

  def try_move(move)
    copy = dup

    if move == :down
      copy.move_down
    elsif move == :left
      copy.move_left
    elsif move == :right
      copy.move_right
    else
      raise "Unknown move: #{move}"
    end
  end

  def position
    [@x, @y]
  end

  def move_down
    @y += 1

    self
  end

  def move_left
    @x -= 1

    self
  end

  def move_right
    @x += 1

    self
  end

  def draw(canvas)
    canvas.write_string("•", x: @x, y: @y, fg: :black, bg: :yellow)
  end
end

GrainsOfSandExample.play(width: 60, height: 20)
