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

      def go(position)
        $stdout.print at(position)
      end

      def at(position)
        case position
        when :home then "\e[H"
        when :up then "\e[A"
        when :down then "\e[B"
        else raise "Invalid cursor position: '#{position}'"
        end
      end
    end
  end
end
