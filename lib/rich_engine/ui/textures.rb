module RichEngine
  # Reusable UI building blocks for games.
  module UI
    # Convenience glyphs for shading and blocky fills.
    module Textures
      extend self

      # The empty glyph (space).
      #
      # @return [String] " "
      def empty
        " "
      end

      # The solid block glyph.
      #
      # @return [String] "█"
      def solid
        "█"
      end

      # The light shade glyph.
      #
      # @return [String] "▓"
      def light_shade
        "▓"
      end

      # The medium shade glyph.
      #
      # @return [String] "▒"
      def medium_shade
        "▒"
      end

      # The dark shade glyph.
      #
      # @return [String] "░"
      def dark_shade
        "░"
      end

      # The upper half block glyph.
      #
      # @return [String] "▀"
      def top_half
        "▀"
      end

      # The lower half block glyph.
      #
      # @return [String] "▄"
      def bottom_half
        "▄"
      end

      # The left half block glyph.
      #
      # @return [String] "▌"
      def left_half
        "▌"
      end

      # The right half block glyph.
      #
      # @return [String] "▐"
      def right_half
        "▐"
      end

      # The plaid (half-shade diagonal) glyph.
      #
      # @return [String] "▞"
      def plaid
        "▞"
      end
    end
  end
end
