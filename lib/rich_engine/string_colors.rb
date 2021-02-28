# frozen_string_literal: true

module RichEngine
  module StringColors
    refine String do
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

      private

      def color(n)
        "\e[#{n}m#{self}\e[0m"
      end
    end
  end
end
