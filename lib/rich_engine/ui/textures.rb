module RichEngine
  module UI
    module Textures
      extend self

      def empty
        " "
      end

      def solid
        "█"
      end

      def light_shade
        "▓"
      end

      def medium_shade
        "▒"
      end

      def dark_shade
        "░"
      end

      def top_half
        "▀"
      end

      def bottom_half
        "▄"
      end

      def left_half
        "▌"
      end

      def right_half
        "▐"
      end

      def plaid
        "▞"
      end
    end
  end
end
