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
      `tput civis`
      i = 0
      output = ''
      while i < canvas_size
        output += "#{canvas[i...(i + @width)].join}\n"

        i += @width
      end

      puts "#{clear_screen}#{output}"
      `tput cnorm`
    end

    def read_async
      char = ''
      $stdin.raw do |io|
        char = io.read_nonblock(4)
      rescue StandardError
        char = nil
      end
      print "\r\e[J"

      return nil if char.nil?

      symbolize_char(char)
    end

    private

    def canvas_size
      @canvas_size ||= @height * @width
    end

    def clear_screen
      "\e[2J\e[f"
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
