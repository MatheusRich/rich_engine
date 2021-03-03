module RichEngine
  module Terminal
    extend self

    def hide_cursor
      system("tput civis")
    end

    def display_cursor
      system("tput cnorm")
    end

    def disable_echo
      system("stty -echo")
    end

    def enable_echo
      system("stty echo")
    end
  end
end