# frozen_string_literal: true

module RichEngine
  module Terminal
    module Cursor
      extend self

      def hide
        system("tput civis")
      end

      def display
        system("tput cnorm")
      end

      def goto(x, y)
        $stdout.goto(x, y)
      end
    end
  end
end
