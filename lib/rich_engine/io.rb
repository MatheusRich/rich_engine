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
      Terminal::Cursor.go(:home)
      output = build_output(canvas)
      puts output
    end

    def read_async
      $stdin.raw do |io|
        key = $stdin.read_nonblock(2)
        c, c2 = key.chars

        if c2 && csi?(key)
          c3, c4 = $stdin.read_nonblock(2).chars

          if digit?(c3)
            symbolize_key(key + c3 + c4)
          else
            symbolize_key(key + c3)
          end
        else
          symbolize_key(key)
        end
      rescue ::IO::WaitReadable
        nil
      end
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

    def symbolize_key(key)
      return key.downcase.to_sym unless key.start_with?("\e", " ")

      case key
      when "\e[A"  then :up
      when "\e[B"  then :down
      when "\e[C"  then :right
      when "\e[D"  then :left
      when "\e"    then :esc
      when " "     then :space
      when "\e[2~" then :insert
      when "\e[3~" then :delete
      when "\e[5~" then :pg_up
      when "\e[6~" then :pg_down
      when "\e[H"  then :home
      when "\e[F"  then :end
      else raise "Unknown key #{key.inspect}" if ENV["DEBUG"] == 'all'
      end
    end

    def escape?(char)
      char == "\e"
    end

    def csi?(str)
      str == "\e["
    end

    def digit?(char)
      ("0".."9").include?(char)
    end
  end
end
