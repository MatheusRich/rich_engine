# frozen_string_literal: true

require_relative "terminal/cursor"

module RichEngine
  module Terminal
    module_function

    def clear
      $stdout.clear_screen
    end

    def hide_cursor
      Cursor.hide
    end

    def display_cursor
      Cursor.display
    end

    def disable_echo
      $stdin.echo = false
    end

    def enable_echo
      $stdin.echo = true
    end
  end
end
