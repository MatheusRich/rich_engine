# frozen_string_literal: true

module RichEngine
  # Colors are emitted as 256-color (8-bit) escape sequences using only the
  # theme-independent regions of the palette: the 6x6x6 color cube (16-231)
  # and the grayscale ramp (232-255). Unlike the classic 16 ANSI colors,
  # these render the same RGB values in every terminal.
  module StringColors
    # Named colors mapped to fixed color-cube/grayscale indices.
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
    CUBE_LEVELS = [0, 95, 135, 175, 215, 255].freeze

    # Resolves a color spec into a 256-color index:
    #
    #   :red           -> named palette color
    #   "#ff8800"      -> nearest cube/grayscale color (also "ff8800", "#f80")
    #   [255, 136, 0]  -> nearest cube/grayscale color
    #   208            -> used as-is
    #
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

    def self.hex_to_rgb(hex)
      digits = hex.delete_prefix("#")
      digits = digits.each_char.map { |c| c * 2 }.join if digits.length == 3
      digits.scan(/../).map { |pair| pair.to_i(16) }
    end

    def self.rgb_to_index(red, green, blue)
      if red == green && green == blue
        gray_index(red)
      else
        r, g, b = [red, green, blue].map { |channel| nearest_cube_level(channel) }
        16 + (36 * r) + (6 * g) + b
      end
    end

    def self.nearest_cube_level(channel)
      CUBE_LEVELS.each_index.min_by { |i| (CUBE_LEVELS[i] - channel).abs }
    end

    # The grayscale ramp (232-255) covers intensities 8, 18, ... 238. Levels
    # near the extremes snap to the cube's black (16) and white (231).
    def self.gray_index(level)
      return 16 if level < 4
      return 231 if level > 243

      232 + ((level - 8) / 10.0).round.clamp(0, 23)
    end

    refine String do
      def fg(color)
        return transparent if color == :transparent

        "\e[38;5;#{StringColors.index_for(color)}m#{self}\e[39m"
      end

      def bg(color)
        return on_transparent if color == :transparent

        "\e[48;5;#{StringColors.index_for(color)}m#{self}\e[49m"
      end

      # Colors

      def transparent
        gsub(/./, " ")
      end

      def on_transparent
        "\e[49m#{self}\e[49m"
      end

      PALETTE.each_key do |name|
        define_method(name) { fg(name) }
        define_method("on_#{name}") { bg(name) }
      end

      # STYLES

      def bold
        "\e[1m#{self}\e[22m"
      end

      def italic
        "\e[3m#{self}\e[23m"
      end

      def underline
        "\e[4m#{self}\e[24m"
      end

      def blink
        "\e[5m#{self}\e[25m"
      end

      def reverse_color
        "\e[7m#{self}\e[27m"
      end
    end
  end
end
