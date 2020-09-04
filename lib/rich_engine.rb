# frozen_string_literal: true

require_relative 'rich_engine/base'
require_relative 'rich_engine/canvas'
require_relative 'rich_engine/io'
require_relative 'rich_engine/timer'
require_relative 'rich_engine/version'

module RichEngine
  class Error < StandardError; end
end
