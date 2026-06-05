# frozen_string_literal: true

require_relative "rich_engine/animation"
require_relative "rich_engine/canvas"
require_relative "rich_engine/chance"
require_relative "rich_engine/cooldown"
require_relative "rich_engine/enum"
require_relative "rich_engine/game"
require_relative "rich_engine/matrix"
require_relative "rich_engine/string_colors"
require_relative "rich_engine/terminal"
require_relative "rich_engine/timer"
require_relative "rich_engine/timer/every"
require_relative "rich_engine/ui/textures"
require_relative "rich_engine/version"

# A tiny terminal game engine for Ruby. It provides a simple game loop, a 2D
# character canvas with colors, non-blocking keyboard input, and a handful of
# helpers (timers, cooldowns, RNG, enums, matrices) so you can ship playful
# ASCII games quickly.
#
# At its core, you subclass {RichEngine::Game}, implement a few lifecycle hooks,
# and draw to a {RichEngine::Canvas} each frame.
module RichEngine
end
