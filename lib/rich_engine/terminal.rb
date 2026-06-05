# frozen_string_literal: true

require_relative "terminal/cursor"

module RichEngine
  # Internal plumbing used by {Game} to prepare and restore the terminal:
  # clearing the screen, toggling cursor visibility, and toggling input echo.
  #
  # @api private
  module Terminal
    module_function

    # Clears the screen.
    #
    # @return [void]
    def clear
      $stdout.clear_screen
    end

    # Hides the terminal cursor.
    #
    # @return [void]
    def hide_cursor
      Cursor.hide
    end

    # Shows the terminal cursor.
    #
    # @return [void]
    def display_cursor
      Cursor.display
    end

    # Stops typed characters from being echoed to the screen.
    #
    # @return [void]
    def disable_echo
      $stdin.echo = false
    end

    # Resumes echoing typed characters to the screen.
    #
    # @return [void]
    def enable_echo
      $stdin.echo = true
    end
  end
end
