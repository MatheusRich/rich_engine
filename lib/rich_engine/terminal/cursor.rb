# frozen_string_literal: true

module RichEngine
  module Terminal
    # Internal plumbing for controlling the terminal cursor: visibility and
    # positioning.
    #
    # @api private
    module Cursor
      extend self

      # Hides the cursor.
      #
      # @return [void]
      def hide
        system("tput civis")
      end

      # Shows the cursor.
      #
      # @return [void]
      def display
        system("tput cnorm")
      end

      # Moves the cursor to the given screen position.
      #
      # @param x [Integer] the column to move to
      # @param y [Integer] the row to move to
      # @return [void]
      def goto(x, y)
        $stdout.goto(x, y)
      end
    end
  end
end
