# frozen_string_literal: true

module RichEngine
  module Terminal
    module Cursor
      module_function

      def hide
        system("tput civis")
      end

      def display
        system("tput cnorm")
      end

      def go(position)
        case position
        when :home then print "\e[H"
        when :up   then print "\e[A"
        when :down then print "\e[B"
        else raise "Invalid cursor position: '#{position}'"
        end
      end
    end
  end
end
