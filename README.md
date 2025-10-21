# RichEngine

RichEngine is a tiny terminal game engine for Ruby. It gives you a simple game loop, a 2D character canvas with colors, non-blocking keyboard input, and a handful of helpers (timers, cooldowns, RNG, enums, matrices) so you can ship playful ASCII games quickly.

At its core, you subclass `RichEngine::Game`, implement a few lifecycle hooks, and draw to a `Canvas` each frame.

## Quick start: build a simple game

Below is a minimal, complete example showing how to:
- create a game by subclassing `RichEngine::Game`
- quit on a key press
- sleep to cap the frame rate
- draw text and shapes to the screen

```ruby
require "rich_engine"

class MyGame < RichEngine::Game
  using RichEngine::StringColors

  TITLE = "Catch the Star"

  PLAYER_CHAR = "@"
  PLAYER_COLOR = :yellow

  ITEM_COLORS = [:green, :magenta, :cyan]
  ITEM_CHAR = "*"

  HUD_HEIGHT = 3

  def on_create
    @score = 0
    @player_x = 2
    @player_y = field_height / 2
    @timer = RichEngine::Cooldown.new(5.0)
    spawn_item
  end

  # elapsed_time: seconds since last frame (Float)
  # key: last key pressed (Symbol) or nil
  def on_update(elapsed_time, key)
    quit! if key == :q || key == :esc

    # Move player with arrow keys
    case key
    when :left  then @player_x -= 1
    when :right then @player_x += 1
    when :up    then @player_y -= 1
    when :down  then @player_y += 1
    end

    # Keep player inside the game field (above the HUD)
    @player_x = @player_x.clamp(0, @width - 1)
    @player_y = @player_y.clamp(0, field_height - 1)

    # Game over if time runs out
    @timer.update(elapsed_time)
    if @timer.finished?
      @game_over = true
      quit!
    end

    # Pick up item -> +1 point, respawn, reset timer
    if @player_x == @item_x && @player_y == @item_y
      @score += 1
      spawn_item
      @timer.reset!
    end

    # drawing to the canvas
    @canvas.clear
    @canvas.bg = RichEngine::UI::Textures.solid.bright_white

    # Item and player
    @canvas.write_string(ITEM_CHAR, x: @item_x, y: @item_y, fg: @item_color, bg: :gray)
    @canvas.write_string(PLAYER_CHAR, x: @player_x, y: @player_y, fg: PLAYER_COLOR, bg: :gray)

    # HUD at the bottom rows
    @canvas.write_string(TITLE.ljust(@width), x: 0, y: hud_y, fg: :bright_cyan)
    @canvas.write_string("Score: #{@score}".ljust(@width), x: 0, y: hud_y + 1, fg: :bright_yellow)
    @canvas.write_string("Time: #{format('%.1f', @timer.get)}s".ljust(@width), x: 0, y: hud_y + 2, fg: :bright_green)

    # sleep to cap FPS
    sleep 1 / 60.0
  end

  def on_destroy
    puts(@game_over ? "Game over! Final score: #{@score}" : "Thanks for playing! Score: #{@score}")
  end

  private

  def hud_y
    @height - HUD_HEIGHT
  end

  def field_height
    @height - HUD_HEIGHT
  end

  def spawn_item
    # Spawn above the HUD so it won't overlap with on-screen text
    @item_x = rand(@width)
    @item_y = rand(field_height)
    @item_color = ITEM_COLORS.sample
  end
end

MyGame.play(width: 50, height: 12)
```

Notes
- Hooks:
  - `on_create` runs once at start
  - `on_update(elapsed_time, key)` runs every frame
  - `on_destroy` runs when the game exits.
- Keys: letters are symbols (e.g., `:q`), plus arrows (`:up`, `:down`, `:left`, `:right`), `:space`, `:enter`, `:esc`, `:pg_up`, `:pg_down`, `:home`, `:end`.
- Drawing: all drawing happens on `@canvas`. Call `@canvas.clear` each frame if you want to redraw from scratch.
- Rendering is handled for you. `Game` will flush the canvas to the terminal after each `on_update`.

## Canvas essentials

`@canvas` exposes a few handy methods:
- `write_string(str, x:, y:, fg: :white, bg: :transparent)` — write colored text; pass a single color or an array (arrays will cycle per character)
- `draw_rect(x:, y:, width:, height:, char: "█", color: :white)` — draw a filled rectangle
- `draw_circle(x:, y:, radius:, char: "█", color: :white)` — draw a filled circle
- `draw_sprite(sprite, x: 0, y: 0, fg: :white)` — draw a multi-line string as a sprite; spaces are transparent
- `clear` — clear the entire canvas; `bg=` changes the background fill character and clears

Colors are provided via a refinement used internally by the canvas. For text, prefer the `fg:` and `bg:` options on `write_string`.

## Helpers you can use

All helpers live under `RichEngine::...` and are independent utilities you can use inside your game code.

### Timer

- `Timer` accumulates elapsed time; you drive it by calling `update(dt)` with the `elapsed_time` from `on_update`.
- `Timer.every(seconds:)` returns a small scheduler that fires a block at a fixed interval.

```ruby
tick = RichEngine::Timer.new

def on_update(dt, _key)
    tick.update(dt)
    if tick.get > 2
        # do something every ~2 seconds
        tick.reset!
    end
end

# Fixed interval
spawn = RichEngine::Timer.every(seconds: 0.5)
def on_update(dt, _key)
    spawn.update(dt)
    spawn.when_ready { spawn_enemy! }
end
```

### Cooldown

Track a fixed delay and check if it’s ready.

```ruby
shoot_cd = RichEngine::Cooldown.new(0.25) # seconds

def on_update(dt, key)
    shoot_cd.update(dt)
    if key == :space && shoot_cd.ready?
        shoot!
        shoot_cd.reset!
    end
end
```

### Chance (random helpers)

```ruby
RichEngine::Chance.of(0.2)   # 20% chance
RichEngine::Chance.of(20)    # also 20% (percent form)
RichEngine::Chance.of_one_in(10) # 1 in 10 chance
```

### Enum and Enum::Mixin

Create ergonomic, comparable enums with query methods.

```ruby
# Standalone enum
STATE = RichEngine::Enum.new(:state, {idle: 0, running: 1, paused: 2})
STATE.idle.value        #=> 0
STATE.running > STATE.idle #=> true

# In a class via Mixin
class Player
    include RichEngine::Enum::Mixin
    enum :state, {idle: 0, running: 1, paused: 2}

    def initialize
        @state = :idle
    end

    def update
        if state.running?
            # ...
        end
    end
end
```

### Matrix (2D grid)

A simple 2D matrix utility with convenience methods.

```ruby
grid = RichEngine::Matrix.new(width: 10, height: 5, fill_with: 0)
grid[2, 3] = 1

grid.each { |cell| puts cell }

# Fill regions
grid.fill(x: 0..2, y: 0..1, with: 9)

# Zip two matrices into pairs
other = RichEngine::Matrix.new(width: 10, height: 5, fill_with: :a)
pairs = grid.zip(other) # => matrix of [left, right]
```

### UI::Textures (useful glyphs)

Convenience characters for shading and blocks: `empty`, `solid`, `light_shade`, `medium_shade`, `dark_shade`, `top_half`, `bottom_half`, `left_half`, `right_half`, `plaid`.

```ruby
@canvas.draw_rect(x: 10, y: 6, width: 8, height: 2, char: RichEngine::UI::Textures.solid, color: :magenta)
```

## Examples

See the `examples/` folder for more complete samples:
- `timer.rb` — using timers and intervals
- `noise.rb` — colorful random output
- `background.rb` — background fill and drawing
- `grains_of_sand.rb` — simple cellular-like simulation

## Install and run locally (optional)

Add to a Gemfile, then bundle:

```ruby
gem "rich_engine"
```

```sh
bundle install
```

Or install directly:

```sh
gem install rich_engine
```

Then run one of the examples:

```sh
ruby examples/timer.rb
```

## License

MIT
