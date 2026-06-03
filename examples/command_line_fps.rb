# frozen_string_literal: true

# Inspired by javidx9's CommandLineFPS raycaster (@OneLoneCoder).

require "rich_engine"

# A billboard sprite: a grid of glyphs with a parallel grid of colors, sampled
# by normalized (0..1) coordinates so it can be scaled to any size.
class Sprite
  using RichEngine::StringColors

  attr_reader :width, :height

  def initialize(glyphs, colors)
    @glyphs = glyphs
    @colors = colors
    @height = glyphs.size
    @width = glyphs.first.size
  end

  def sample(sample_x, sample_y)
    gx = clamp((sample_x * @width).to_i, @width)
    gy = clamp((sample_y * @height).to_i, @height)

    glyph = @glyphs[gy][gx]
    return nil if glyph == " "

    color = @colors[gy][gx]
    color ? glyph.fg(color) : glyph
  end

  # A square target: yellow bull, then concentric red/white square rings.
  def self.bullseye(radius)
    size = radius * 2 + 1
    glyphs = Array.new(size) { Array.new(size, "█") }
    colors = Array.new(size) { Array.new(size) }

    (0...size).each do |row|
      (0...size).each do |col|
        ring = [(col - radius).abs, (row - radius).abs].max # Nested 1-cell squares
        colors[row][col] =
          if ring.zero? then :bright_yellow # Bull
          elsif ring.odd? then :bright_red
          else :white
          end
      end
    end

    new(glyphs, colors)
  end

  # A glowing orb: yellow core fading to red.
  def self.fireball(radius)
    radial(radius) do |ratio|
      ratio <= 0.5 ? :bright_yellow : :bright_red
    end
  end

  # Builds a filled disc of "█", coloring each pixel by its distance ratio
  # (0 at center, 1 at the rim). Pixels outside the disc are transparent.
  def self.radial(radius)
    size = radius * 2 + 1
    glyphs = Array.new(size) { Array.new(size, " ") }
    colors = Array.new(size) { Array.new(size) }

    (0...size).each do |row|
      (0...size).each do |col|
        distance = Math.hypot(col - radius, row - radius)
        next if distance > radius

        glyphs[row][col] = "█"
        colors[row][col] = yield(distance / radius)
      end
    end

    new(glyphs, colors)
  end

  def clamp(value, size)
    value.clamp(0, size - 1)
  end
end

class CommandLineFPS < RichEngine::Game
  using RichEngine::StringColors

  Target = Struct.new(:x, :y)
  Fireball = Struct.new(:x, :y, :vx, :vy, :traveled)

  MAP_WIDTH = 32
  MAP_HEIGHT = 32

  # # = wall block, . = empty space. A 3x3 grid of rooms joined by doorways.
  MAP = [
    "################################",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#..............................#",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#####.#########.##########.#####",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#..............................#",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#####.#########.##########.#####",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#..............................#",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "#.........#..........#.........#",
    "################################"
  ].join

  FOV = Math::PI / 4.0   # Field of view
  DEPTH = 16.0           # Maximum rendering distance
  SPEED = 5.0            # Walking speed
  TIME_LIMIT = 90.0      # Seconds to clear every target

  BULLET_SPEED = 8.0     # Fireball travel speed (units/second)
  BULLET_RANGE = 6.0     # How far a fireball flies before fizzling out
  FIRE_COOLDOWN = 0.25   # Seconds between shots
  HIT_RADIUS = 0.6       # How close a fireball must get to pop a target
  TARGET_SCALE = 0.5     # Target size as a fraction of full wall height
  FIREBALL_SCALE = 0.2

  TARGET_SPRITE = Sprite.bullseye(3)
  FIREBALL_SPRITE = Sprite.fireball(2)

  NUM_TARGETS = 6       # Targets scattered each round
  MIN_SEPARATION = 5.0  # Min distance between targets and from the player spawn

  # Wall texture/brightness ramp, nearest -> farthest.
  WALLS = [
    "█".fg(:white),
    "▓".fg(:light_gray),
    "▒".fg(:light_gray),
    "░".fg(:gray)
  ].freeze

  # Sky gradient, top of screen -> horizon.
  SKY = [
    "░".fg(:blue),
    "▒".fg(:blue),
    "▓".fg(:bright_blue)
  ].freeze

  # Grassy floor, closest (bottom of screen) -> horizon.
  FLOOR = [
    "▓".fg(:green),
    "▒".fg(:green),
    "░".fg(:green),
    "░".fg(:gray)
  ].freeze

  # Player facing indicator on the minimap, indexed clockwise from east.
  DIR_ARROWS = ["→", "↘", "↓", "↙", "←", "↖", "↑", "↗"].freeze

  RADAR_RADIUS = 6 # Half-width of the player-centered minimap window (cells)
  MINIMAP_X = 1    # Top-left screen origin of the minimap contents
  MINIMAP_Y = 2

  def on_create
    reset_game
    @state = :intro # The briefing shows once, before the first round
  end

  def on_update(elapsed_time, key)
    quit! if key == :esc

    case @state
    when :intro
      draw_intro
      @state = :playing if key # Any key begins the round
    when :playing
      play_frame(elapsed_time, key)
    else
      reset_game if key == :r
      draw_result # Freeze the last frame and overlay the win/lose banner
    end
  end

  private

  def reset_game
    spawn_player
    @fps = 0.0
    @state = :playing

    @targets = spawn_targets
    @target_count = @targets.size # Frozen total for the HUD/result screens
    @fireballs = []
    @hits = 0
    @fire_cooldown = RichEngine::Cooldown.new(FIRE_COOLDOWN)
    @clock = RichEngine::Cooldown.new(TIME_LIMIT) # Counts down to zero
    @depth_buffer = Array.new(@width, DEPTH)      # Wall distance per screen column
  end

  def spawn_player
    row, col = open_cells.sample
    @player_x = row + 0.5
    @player_y = col + 0.5
    @player_a = rand * 2 * Math::PI
  end

  def spawn_targets
    chosen = []
    open_cells.shuffle.each do |row, col|
      x = row + 0.5
      y = col + 0.5
      next if Math.hypot(x - @player_x, y - @player_y) < MIN_SEPARATION
      next if chosen.any? { |t| Math.hypot(t.x - x, t.y - y) < MIN_SEPARATION }

      chosen << Target.new(x, y)
      break if chosen.size >= NUM_TARGETS
    end
    chosen
  end

  def open_cells
    @open_cells ||= (0...MAP_HEIGHT).flat_map do |row|
      (0...MAP_WIDTH).filter_map { |col| [row, col] unless wall?(row, col) }
    end
  end

  def play_frame(elapsed_time, key)
    @fps = elapsed_time.zero? ? 0.0 : 1.0 / elapsed_time

    @clock.update(elapsed_time)
    @fire_cooldown.update(elapsed_time)
    handle_input(key, elapsed_time)
    update_fireballs(elapsed_time)

    render_world
    draw_objects
    draw_map
    draw_crosshair
    draw_hud

    if @targets.empty?
      @state = :won
    elsif @clock.finished?
      @state = :lost
    end
  end

  def handle_input(key, elapsed_time)
    case key
    when :a # Rotate counter-clockwise
      @player_a -= (SPEED * 0.75) * elapsed_time
    when :d # Rotate clockwise
      @player_a += (SPEED * 0.75) * elapsed_time
    when :w # Forwards (with collision)
      dx = Math.sin(@player_a) * SPEED * elapsed_time
      dy = Math.cos(@player_a) * SPEED * elapsed_time
      move(dx, dy)
    when :s # Backwards (with collision)
      dx = Math.sin(@player_a) * SPEED * elapsed_time
      dy = Math.cos(@player_a) * SPEED * elapsed_time
      move(-dx, -dy)
    when :q # Strafe left
      strafe(-1, elapsed_time)
    when :e # Strafe right
      strafe(1, elapsed_time)
    when :space
      fire! if @fire_cooldown.ready?
    end
  end

  # Sidestep perpendicular to the facing direction. +1 is right, -1 is left.
  def strafe(direction, elapsed_time)
    dx = Math.cos(@player_a) * SPEED * elapsed_time * direction
    dy = -Math.sin(@player_a) * SPEED * elapsed_time * direction
    move(dx, dy)
  end

  def move(dx, dy)
    @player_x += dx
    @player_y += dy

    if wall?(@player_x.to_i, @player_y.to_i)
      @player_x -= dx
      @player_y -= dy
    end
  end

  def fire!
    # Aim where the player faces, with a little spread.
    angle = @player_a + (rand - 0.5) * 0.1
    @fireballs << Fireball.new(
      @player_x, @player_y,
      Math.sin(angle) * BULLET_SPEED,
      Math.cos(angle) * BULLET_SPEED,
      0.0
    )
    @fire_cooldown.reset!
  end

  def update_fireballs(elapsed_time)
    @fireballs.each do |fireball|
      fireball.x += fireball.vx * elapsed_time
      fireball.y += fireball.vy * elapsed_time
      fireball.traveled += BULLET_SPEED * elapsed_time
    end

    @fireballs.reject! { |fireball| fireball_spent?(fireball) }
  end

  # A fireball is spent when it outranges, leaves the map, buries into a wall,
  # or pops a target. Popping a target removes it and scores a hit.
  def fireball_spent?(fireball)
    return true if fireball.traveled >= BULLET_RANGE

    x = fireball.x.to_i
    y = fireball.y.to_i
    return true if x < 0 || x >= MAP_WIDTH || y < 0 || y >= MAP_HEIGHT
    return true if wall?(x, y)

    hit = @targets.find { |target| Math.hypot(target.x - fireball.x, target.y - fireball.y) < HIT_RADIUS }
    if hit
      @targets.delete(hit)
      @hits += 1
      return true
    end

    false
  end

  def render_world
    (0...@width).each do |x|
      distance, boundary = cast_ray(x)
      @depth_buffer[x] = distance

      ceiling = (@height / 2.0) - @height / distance
      floor = @height - ceiling

      wall = boundary ? " " : wall_tile(distance) # Black out tile boundaries

      (0...@height).each do |y|
        @canvas[x, y] =
          if y <= ceiling
            sky_tile(y, ceiling)
          elsif y <= floor
            wall
          else
            floor_tile(y)
          end
      end
    end
  end

  # Cast a single ray for screen column +x+, returning [distance, boundary?].
  def cast_ray(x)
    ray_angle = (@player_a - FOV / 2.0) + (x.to_f / @width) * FOV

    step_size = 0.1
    distance = 0.0
    hit_wall = false
    boundary = false

    eye_x = Math.sin(ray_angle) # Unit vector for ray in player space
    eye_y = Math.cos(ray_angle)

    while !hit_wall && distance < DEPTH
      distance += step_size
      test_x = (@player_x + eye_x * distance).to_i
      test_y = (@player_y + eye_y * distance).to_i

      if test_x < 0 || test_x >= MAP_WIDTH || test_y < 0 || test_y >= MAP_HEIGHT
        # Out of bounds: clamp to maximum depth
        hit_wall = true
        distance = DEPTH
      elsif wall?(test_x, test_y)
        hit_wall = true
        boundary = tile_boundary?(test_x, test_y, eye_x, eye_y)
      end
    end

    [distance, boundary]
  end

  # Highlight tile boundaries: cast a ray from each corner of the hit tile back
  # to the player. The more coincident a corner ray is with the rendering ray,
  # the closer we are to an edge, which we shade to add detail to the walls.
  def tile_boundary?(test_x, test_y, eye_x, eye_y)
    corners = []

    2.times do |tx|
      2.times do |ty|
        vx = test_x + tx - @player_x
        vy = test_y + ty - @player_y
        d = Math.sqrt(vx * vx + vy * vy)
        dot = (eye_x * vx / d) + (eye_y * vy / d)
        corners << [d, dot]
      end
    end

    corners.sort_by!(&:first) # Closest corners first

    bound = 0.01
    # The first three corners are the closest (we never see all four)
    corners.first(3).any? { |(_d, dot)| Math.acos(dot) < bound }
  end

  # Project every object into the view and draw it as a billboard, scaled by
  # distance and clipped wherever a nearer wall (or sprite) sits in front.
  def draw_objects
    renderables = []
    @targets.each { |t| renderables << [t.x, t.y, TARGET_SPRITE, TARGET_SCALE] }
    @fireballs.each { |f| renderables << [f.x, f.y, FIREBALL_SPRITE, FIREBALL_SCALE] }
    renderables.each { |r| r << Math.hypot(r[0] - @player_x, r[1] - @player_y) }
    renderables.sort_by! { |r| -r.last } # Farthest first, so nearer overdraws

    eye_x = Math.sin(@player_a)
    eye_y = Math.cos(@player_a)

    renderables.each do |ox, oy, sprite, scale, distance|
      next if distance < 0.5 || distance >= DEPTH

      angle = Math.atan2(eye_y, eye_x) - Math.atan2(oy - @player_y, ox - @player_x)
      angle += 2 * Math::PI while angle < -Math::PI
      angle -= 2 * Math::PI while angle > Math::PI
      next unless angle.abs < FOV / 2.0

      ceiling = (@height / 2.0) - @height / distance
      floor = @height - ceiling
      full_height = floor - ceiling

      height = full_height * scale
      # Stretch width to counter the terminal's ~2:1 cell aspect (rounder discs)
      width = height * 2.0 * (sprite.width.to_f / sprite.height)
      top = (@height / 2.0) - height / 2.0
      middle_column = (0.5 * (angle / (FOV / 2.0)) + 0.5) * @width

      draw_billboard(sprite, distance, width, height, top, middle_column)
    end
  end

  def draw_billboard(sprite, distance, width, height, top, middle_column)
    return if width <= 0 || height <= 0

    (0...width.ceil).each do |lx|
      column = (middle_column + lx - width / 2.0).to_i
      next if column < 0 || column >= @width
      next if @depth_buffer[column] < distance # Wall in front: skip this column

      drew = false
      (0...height.ceil).each do |ly|
        pixel = sprite.sample(lx / width, ly / height)
        next unless pixel

        row = (top + ly).to_i
        next if row < 0 || row >= @height

        @canvas[column, row] = pixel
        drew = true
      end

      @depth_buffer[column] = distance if drew # Occlude farther sprites
    end
  end

  def wall_tile(distance)
    if distance <= DEPTH / 4.0 then WALLS[0]   # Very close
    elsif distance < DEPTH / 3.0 then WALLS[1]
    elsif distance < DEPTH / 2.0 then WALLS[2]
    elsif distance < DEPTH then WALLS[3]
    else " "                                   # Too far away
    end
  end

  def sky_tile(y, ceiling)
    s = ceiling <= 0 ? 1.0 : y / ceiling # 0 at top of screen -> 1 at horizon

    if s < 0.5 then SKY[0]
    elsif s < 0.8 then SKY[1]
    else SKY[2]
    end
  end

  def floor_tile(y)
    b = 1.0 - ((y - @height / 2.0) / (@height / 2.0)) # 0 closest -> 1 horizon

    if b < 0.25 then FLOOR[0]
    elsif b < 0.5 then FLOOR[1]
    elsif b < 0.75 then FLOOR[2]
    elsif b < 0.9 then FLOOR[3]
    else " "
    end
  end

  def wall?(x, y)
    MAP[x * MAP_WIDTH + y] == "#"
  end

  # A player-centered radar: a small window of the map that scrolls with you,
  # drawn 1:1 so walls and doorways stay crisp. North stays up.
  def draw_map
    draw_minimap_frame

    px = @player_x.to_i
    py = @player_y.to_i

    (-RADAR_RADIUS..RADAR_RADIUS).each do |dr|
      (-RADAR_RADIUS..RADAR_RADIUS).each do |dc|
        plot_radar(dr, dc, radar_glyph(px + dr, py + dc))
      end
    end

    # Targets blip on the radar whenever they come within range.
    @targets.each do |t|
      dr = t.x.to_i - px
      dc = t.y.to_i - py
      next if dr.abs > RADAR_RADIUS || dc.abs > RADAR_RADIUS
      plot_radar(dr, dc, "◎".fg(:bright_red))
    end

    plot_radar(0, 0, player_arrow.fg(:bright_yellow)) # Player is always centered
  end

  def radar_glyph(row, col)
    if row < 0 || row >= MAP_HEIGHT || col < 0 || col >= MAP_WIDTH
      "█".fg(:gray) # Outside the map
    elsif wall?(row, col)
      "█".fg(:white)
    else
      "·".fg(:gray)
    end
  end

  # Plot a map cell at offset (dr, dc) from the player onto the radar window.
  def plot_radar(dr, dc, glyph)
    @canvas[MINIMAP_X + dc + RADAR_RADIUS, MINIMAP_Y + dr + RADAR_RADIUS] = glyph
  end

  def draw_minimap_frame
    size = 2 * RADAR_RADIUS + 1
    left = MINIMAP_X - 1
    right = MINIMAP_X + size
    top = MINIMAP_Y - 1
    bottom = MINIMAP_Y + size
    color = :gray

    (left..right).each do |x|
      @canvas[x, top] = "─".fg(color)
      @canvas[x, bottom] = "─".fg(color)
    end
    (top..bottom).each do |y|
      @canvas[left, y] = "│".fg(color)
      @canvas[right, y] = "│".fg(color)
    end
    @canvas[left, top] = "┌".fg(color)
    @canvas[right, top] = "┐".fg(color)
    @canvas[left, bottom] = "└".fg(color)
    @canvas[right, bottom] = "┘".fg(color)
  end

  def player_arrow
    index = (@player_a / (Math::PI / 4.0)).round % 8
    DIR_ARROWS[index]
  end

  def draw_crosshair
    cx = @width / 2
    cy = @height / 2
    @canvas[cx - 1, cy] = "─".fg(:bright_green)
    @canvas[cx + 1, cy] = "─".fg(:bright_green)
    @canvas[cx, cy] = "┼".fg(:bright_green)
  end

  def draw_hud
    remaining = [@clock.get, 0.0].max
    time_color = remaining <= 10 ? :bright_red : :white
    @canvas.write_string(format("TIME %4.1f", remaining), x: 0, y: 0, fg: time_color)
    @canvas.write_string("HITS #{@hits}  LEFT #{@targets.size}", x: @width - 16, y: 0, fg: :bright_yellow)
    @canvas.write_string(format("FPS %3.0f", @fps), x: @width - 16, y: 1, fg: :gray)
    @canvas.write_string("W/S move   A/D turn   Q/E strafe   SPACE fire   ESC quit", x: 0, y: @height - 1, fg: :gray)
  end

  def draw_intro
    cy = @height / 2
    @canvas.write_string("TARGET RANGE", x: :center, y: cy - 4, fg: :bright_green)
    @canvas.write_string("Hunt down all #{@target_count} targets in #{TIME_LIMIT.to_i} seconds.", x: :center, y: cy - 1, fg: :white)
    @canvas.write_string("They blip on the radar when you get close. Go hunt them down.", x: :center, y: cy + 1, fg: :white)
    @canvas.write_string("W/S move   A/D turn   Q/E strafe   SPACE fire", x: :center, y: cy + 3, fg: :bright_yellow)
    @canvas.write_string("Press any key to begin", x: :center, y: cy + 5, fg: :white)
  end

  def draw_result
    if @state == :won
      headline = "TARGETS CLEARED!"
      headline_color = :bright_green
      detail = format("Cleared in %.1fs", TIME_LIMIT - [@clock.get, 0.0].max)
    else
      headline = "TIME'S UP!"
      headline_color = :bright_red
      detail = "Hits #{@hits}/#{@target_count}"
    end

    @canvas.write_string(headline, x: :center, y: @height / 2 - 2, fg: headline_color)
    @canvas.write_string(detail, x: :center, y: @height / 2, fg: :white)
    @canvas.write_string("Press R to play again   ESC to quit", x: :center, y: @height / 2 + 2, fg: :white)
  end
end

CommandLineFPS.play(width: 120, height: 40)
