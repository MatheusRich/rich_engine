# frozen_string_literal: true

module RichEngine
  # A refinement that adds color and style methods to String, plus helpers
  # for resolving color specs.
  #
  # Colors are emitted as 256-color (8-bit) escape sequences using only the
  # theme-independent regions of the palette: the 6x6x6 color cube (16-231)
  # and the grayscale ramp (232-255). Unlike the classic 16 ANSI colors,
  # these render the same RGB values in every terminal.
  #
  # Anywhere a color is accepted, you can pass:
  #
  # - a named color (`Symbol`): `:red`, `:bright_cyan`, ... (see {PALETTE})
  # - a hex string: `"#ff8800"` (also `"ff8800"` and shorthand `"#f80"`)
  # - an RGB array: `[255, 136, 0]`
  # - a raw 256-color index (`Integer`): `208`
  #
  # Hex and RGB values snap to the nearest color in the fixed 256-color
  # palette.
  #
  # @example
  #   using RichEngine::StringColors
  #
  #   "hello".fg(:red)            # named color
  #   "hello".fg("#ff8800").bold  # custom color, chained with a style
  #   "hello".bg([0, 0, 215])     # RGB background
  module StringColors
    # Named colors mapped to fixed color-cube/grayscale indices.
    #
    # @return [Hash{Symbol => Integer}]
    PALETTE = {
      black: 16,
      red: 160,
      green: 40,
      yellow: 184,
      orange: 208,
      blue: 20,
      magenta: 164,
      cyan: 44,
      white: 231,
      dark_gray: 238,
      dark_grey: 238,
      gray: 244,
      grey: 244,
      light_gray: 188,
      light_grey: 188,
      bright_red: 196,
      bright_green: 46,
      bright_yellow: 226,
      bright_blue: 21,
      bright_magenta: 201,
      bright_cyan: 51
    }.freeze

    # Channel intensities used by the 6x6x6 color cube.
    #
    # @return [Array<Integer>]
    CUBE_LEVELS = [0, 95, 135, 175, 215, 255].freeze

    # Resolves a color spec into a 256-color index.
    #
    # @example
    #   index_for(:red)          # => 160 (named palette color)
    #   index_for("#ff8800")     # => 208 (nearest cube color)
    #   index_for([255, 136, 0]) # => 208 (nearest cube color)
    #   index_for(208)           # => 208 (used as-is)
    #
    # @param color [Symbol, String, Array<Integer>, Integer] a color spec
    # @return [Integer] an index into the 256-color palette
    # @raise [ArgumentError] if the spec is not one of the supported types
    # @raise [KeyError] if a named color is not in {PALETTE}
    def self.index_for(color)
      case color
      when Symbol then PALETTE.fetch(color)
      when Integer then color
      when Array then rgb_to_index(*color)
      when String then rgb_to_index(*hex_to_rgb(color))
      else
        raise ArgumentError, "invalid color: #{color.inspect}"
      end
    end

    # Returns `:black` or `:white`, whichever has the higher WCAG contrast
    # ratio against the given color, like CSS's `contrast-color()` function.
    # Ties go to `:white`.
    #
    # @example Readable labels on a dynamic background
    #   label_color = StringColors.contrast_color(bg_color)
    #   canvas.write_string("Score", x: 0, y: 0, fg: label_color, bg: bg_color)
    #
    # @example
    #   contrast_color(:yellow)   # => :black
    #   contrast_color("#0000d7") # => :white
    #
    # @param color [Symbol, String, Array<Integer>, Integer] a color spec
    #   (raw indices 0-15 raise, since their RGB values are theme-dependent)
    # @return [Symbol] `:black` or `:white`
    def self.contrast_color(color)
      luminance = relative_luminance(rgb_for(color))
      white_contrast = 1.05 / (luminance + 0.05)
      black_contrast = (luminance + 0.05) / 0.05

      (white_contrast >= black_contrast) ? :white : :black
    end

    # Resolves a color spec into `[r, g, b]` channel values.
    #
    # @api private
    def self.rgb_for(color)
      case color
      when Symbol then index_to_rgb(PALETTE.fetch(color))
      when Integer then index_to_rgb(color)
      when Array then color
      when String then hex_to_rgb(color)
      else
        raise ArgumentError, "invalid color: #{color.inspect}"
      end
    end

    # Converts a 256-color index (16-255) back into `[r, g, b]` values.
    #
    # @api private
    def self.index_to_rgb(index)
      if index.between?(16, 231)
        cube = index - 16
        [cube / 36, (cube % 36) / 6, cube % 6].map { |level| CUBE_LEVELS[level] }
      elsif index.between?(232, 255)
        level = 8 + (10 * (index - 232))
        [level, level, level]
      else
        raise ArgumentError, "color index #{index} is theme-dependent; use 16-255"
      end
    end

    # WCAG 2 relative luminance of an sRGB color, from 0.0 (black) to 1.0
    # (white). See https://www.w3.org/TR/WCAG20/#relativeluminancedef
    #
    # @api private
    def self.relative_luminance(rgb)
      r, g, b = rgb.map do |channel|
        value = channel / 255.0
        (value <= 0.04045) ? value / 12.92 : ((value + 0.055) / 1.055)**2.4
      end

      (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
    end

    # Parses `"#rrggbb"`, `"rrggbb"`, or `"#rgb"` into `[r, g, b]` values.
    #
    # @api private
    def self.hex_to_rgb(hex)
      digits = hex.delete_prefix("#")
      digits = digits.each_char.map { |c| c * 2 }.join if digits.length == 3
      digits.scan(/../).map { |pair| pair.to_i(16) }
    end

    # Snaps `[r, g, b]` values to the nearest cube/grayscale index.
    #
    # @api private
    def self.rgb_to_index(red, green, blue)
      if red == green && green == blue
        gray_index(red)
      else
        r, g, b = [red, green, blue].map { |channel| nearest_cube_level(channel) }
        16 + (36 * r) + (6 * g) + b
      end
    end

    # Index of the cube level (0-5) closest to the given channel value.
    #
    # @api private
    def self.nearest_cube_level(channel)
      CUBE_LEVELS.each_index.min_by { |i| (CUBE_LEVELS[i] - channel).abs }
    end

    # The grayscale ramp (232-255) covers intensities 8, 18, ... 238. Levels
    # near the extremes snap to the cube's black (16) and white (231).
    #
    # @api private
    def self.gray_index(level)
      return 16 if level < 4
      return 231 if level > 243

      232 + ((level - 8) / 10.0).round.clamp(0, 23)
    end

    refine String do
      # Colors the string's foreground.
      #
      # @example
      #   "hello".fg(:red)
      #   "hello".fg("#ff8800")
      #
      # @param color [Symbol, String, Array<Integer>, Integer] a color spec
      #   (see {StringColors}); `:transparent` replaces the text with spaces
      # @return [String] the string wrapped in escape sequences
      def fg(color)
        return transparent if color == :transparent

        "\e[38;5;#{StringColors.index_for(color)}m#{self}\e[39m"
      end

      # Colors the string's background.
      #
      # @example
      #   "hello".bg(:cyan)
      #   "hello".bg("#222222")
      #
      # @param color [Symbol, String, Array<Integer>, Integer] a color spec
      #   (see {StringColors}); `:transparent` keeps the terminal's default
      #   background
      # @return [String] the string wrapped in escape sequences
      def bg(color)
        return on_transparent if color == :transparent

        "\e[48;5;#{StringColors.index_for(color)}m#{self}\e[49m"
      end

      # Colors

      # Replaces every character with a space.
      #
      # @return [String]
      def transparent
        gsub(/./, " ")
      end

      # Renders the string on the terminal's default background.
      #
      # @return [String]
      def on_transparent
        "\e[49m#{self}\e[49m"
      end

      # @!macro [attach] palette_color
      #   @!method $1
      #     Colors the foreground `$1` (equivalent to `fg(:$1)`).
      #     @return [String]
      #   @!method on_$1
      #     Colors the background `$1` (equivalent to `bg(:$1)`).
      #     @return [String]
      PALETTE.each_key do |name|
        define_method(name) { fg(name) }
        define_method("on_#{name}") { bg(name) }
      end

      # STYLES

      # @return [String] the string styled bold
      def bold
        "\e[1m#{self}\e[22m"
      end

      # @return [String] the string styled italic
      def italic
        "\e[3m#{self}\e[23m"
      end

      # @return [String] the string underlined
      def underline
        "\e[4m#{self}\e[24m"
      end

      # @return [String] the string styled blinking
      def blink
        "\e[5m#{self}\e[25m"
      end

      # @return [String] the string with foreground and background swapped
      def reverse_color
        "\e[7m#{self}\e[27m"
      end
    end
  end
end
