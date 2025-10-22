# frozen_string_literal: true

module RichEngine
  module StringColors
    refine String do
      def fg(color)
        send(color)
      end

      def bg(color)
        send("on_#{color}")
      end

      # Colors

      def transparent
        gsub(/./, " ")
      end

      def black
        color(30)
      end

      def red
        color(31)
      end

      def green
        color(32)
      end

      def yellow
        color(33)
      end

      def blue
        color(34)
      end

      def magenta
        color(35)
      end

      def cyan
        color(36)
      end

      def white
        color(37)
      end

      def bright_black
        color(90)
      end

      def bright_red
        color(91)
      end

      def bright_green
        color(92)
      end

      def bright_yellow
        color(93)
      end

      def bright_blue
        color(94)
      end

      def bright_magenta
        color(95)
      end

      def bright_cyan
        color(96)
      end

      def bright_white
        color(97)
      end

      # Background colors

      def on_black
        color(40)
      end

      def on_red
        color(41)
      end

      def on_green
        color(42)
      end

      def on_yellow
        color(43)
      end

      def on_blue
        color(44)
      end

      def on_magenta
        color(45)
      end

      def on_cyan
        color(46)
      end

      def on_white
        color(47)
      end

      def on_transparent
        color(49)
      end

      def on_bright_black
        color(100)
      end

      def on_bright_red
        color(101)
      end

      def on_bright_green
        color(102)
      end

      def on_bright_yellow
        color(103)
      end

      def on_bright_blue
        color(104)
      end

      def on_bright_magenta
        color(105)
      end

      def on_bright_cyan
        color(106)
      end

      def on_bright_white
        color(107)
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

      def color(n)
        "\e[#{n}m#{self}\e[0m"
      end
    end
  end
end
