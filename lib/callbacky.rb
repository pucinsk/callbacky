# frozen_string_literal: true

module Callbacky
  module ClassMethods
    def callbacky_callbacks
      @callbacky_callbacks ||= Hash.new do |events_hash, event|
        events_hash[event] = Hash.new { |methods_hash, cycle| methods_hash[cycle] = [] }
      end
    end

    def callbacky(cycle, event, *methods, &block)
      store_callbacks(cycle, event, *methods, &block)
      define_callback_executor(event) unless method_defined?("callbacky_#{event}")
    end

    private

    def store_callbacks(cycle, event, *methods, &block)
      callbacks = callbacky_callbacks[event][cycle]
      methods.each { |method| callbacks << method unless callbacks.include?(method) }
      callbacks << block if block_given?
    end

    def define_callback_executor(event)
      define_method("callbacky_#{event}") do |&block|
        run_callback_cycle(:before, event)
        block&.call(self)
        run_callback_cycle(:after, event)
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  private

  def run_callback_cycle(cycle, event)
    callbacks = self.class.callbacky_callbacks.dig(event, cycle) || []
    callbacks.each do |callback|
      callback.is_a?(Proc) ? callback.call(self) : send(callback)
    end
  end
end
