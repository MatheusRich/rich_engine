# frozen_string_literal: true

require 'timeout'
require 'io/console'

module RichEngine
  class IO
    def initialize(width, height)
      @width = width
      @height = height
    end

    def write(canvas)
      i = 0
      output = ''
      while i < canvas_size
        output += "#{canvas[i...(i + @width)].join}\n"

        i += @width
      end
      puts clear_screen + output
    end

    def read_async
      system('stty raw -echo')
      char = begin
               $stdin.read_nonblock(4)
             rescue StandardError
               nil
             end
      system('stty -raw echo')
      print "\r\e[J"

      return nil if char.nil?

      symbolize_char(char)
    end

    private

    def canvas_size
      @canvas_size ||= @height * @width
    end

    def clear_screen
      @clear_screen ||= "\r#{"\e[A\e[K" * 3}" * @height
    end

    def symbolize_char(char)
      char = char.to_sym

      case char
      when :"\e[A"
        char = :up
      when :"\e[B"
        char = :down
      when :"\e[C"
        char = :right
      when :"\e[D"
        char = :left
      end

      char
    end
  end
end
