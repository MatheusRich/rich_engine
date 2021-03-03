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
      move_cursor_to_home
      output = build_output(canvas)
      puts output
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

    def build_output(canvas)
      output = ''

      i = 0
      while i < canvas_size
        output += "#{canvas[i...(i + @width)].join}\n"

        i += @width
      end

      output
    end

    def canvas_size
      @canvas_size ||= @height * @width
    end

    def move_cursor_to_home
      print "\e[H"
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
