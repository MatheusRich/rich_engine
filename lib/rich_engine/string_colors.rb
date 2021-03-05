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

      def transparent
        gsub(/./, ' ')
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

      def brown
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

      def on_transparent
        color(49)
      end

      def on_black
        color(40)
      end

      def on_red
        color(41)
      end

      def on_green
        color(42)
      end

      def on_brown
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

      def on_gray
        color(47)
      end

      def on_transparent
        color(49)
      end

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

      private

      def color(n)
        "\e[#{n}m#{self}\e[0m"
      end
    end
  end
end
