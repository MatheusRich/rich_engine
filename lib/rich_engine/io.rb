# frozen_string_literal: true

require "timeout"
require "io/console"

module RichEngine
  class IO
    Signal.trap("INT") { raise Game::Exit }

    def initialize(width, height)
      @screen_width = width
      @screen_height = height
      @canvas_cache = nil
    end

    def write(canvas, use_caching:)
      delete_cache unless use_caching

      with_caching(canvas) do
        Terminal::Cursor.goto(0, 0)
        output = build_output(canvas)
        $stdout.write output
      end
    end

    def read_async
      $stdin.raw do |io|
        key = $stdin.read_nonblock(2)
        _c1, c2 = key.chars

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

    def delete_cache
      @canvas_cache = nil
    end

    def with_caching(canvas)
      return :cache_hit if canvas == @canvas_cache && ENV["CACHING"]

      yield
      @canvas_cache = canvas

      :cache_miss
    end

    def build_output(canvas)
      output = ""

      i = 0
      while i < canvas_size
        output += "#{canvas[i...(i + @screen_width)].join}\n"

        i += @screen_width
      end

      output
    end

    def canvas_size
      @canvas_size ||= @screen_height * @screen_width
    end

    def symbolize_key(key)
      return key.downcase.to_sym unless key.start_with?("\e", " ", "\n")

      case key
      when "\e[A" then :up
      when "\e[B" then :down
      when "\e[C" then :right
      when "\e[D" then :left
      when "\e" then :esc
      when " " then :space
      when "\n" then :enter
      when "\e[2~" then :insert
      when "\e[3~" then :delete
      when "\e[5~" then :pg_up
      when "\e[6~" then :pg_down
      when "\e[H" then :home
      when "\e[F" then :end
      else raise "Unknown key #{key.inspect}" if ENV["DEBUG"] == "all"
      end
    end

    def escape?(char)
      char == "\e"
    end

    def csi?(str)
      str == "\e["
    end

    def digit?(char)
      char.between?("0", "9")
    end
  end
end
