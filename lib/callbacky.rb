# frozen_string_literal: true

require_relative "callbacky/version"

module Callbacky
  VALID_LIFECYCLES = %i[before after].freeze
  class << self
    def define_callback(lifecycle_event)
      unless VALID_LIFECYCLES.include?(lifecycle_event)
        raise ArgumentError,
              "Valid life cycles are: #{VALID_LIFECYCLES}. #{lifecycle_event} was passed"
      end

      define_method(lifecycle_event) do |event|
        define_method("#{lifecycle_event}_#{event}") do |callback_method_or_block = nil, &block|
          kallbacks = instance_variable_get("@#{lifecycle_event}_kallbacks") || []
          kallbacks << callback_method_or_block if callback_method_or_block
          kallbacks << block if block
          instance_variable_set("@#{lifecycle_event}_kallbacks", kallbacks)
        end

        define_method("execute_#{event}_callbacks") do |obj, &block|
          before_kallbacks = instance_variable_get(:@before_kallbacks)
          before_kallbacks.each { it.is_a?(Proc) ? it.call(obj) : obj.send(it) } if before_kallbacks
          yield if block
          after_kallbacks = instance_variable_get(:@after_kallbacks)
          after_kallbacks.each { it.is_a?(Proc) ? it.call(obj) : obj.send(it) } if after_kallbacks
        end
      end
    end
  end

  VALID_LIFECYCLES.each do
    define_callback(it)
  end
end
