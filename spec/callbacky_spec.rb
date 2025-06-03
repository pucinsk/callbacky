# frozen_string_literal: true

RSpec.describe Callbacky do
  let(:klass) do
    Class.new do
      class << self
        extend Callbacky

        callbacky_after :init
      end

      attr_reader :callback_handler

      def initialize(callback_handler:)
        @callback_handler = callback_handler

        self.class.callbacky_init(self)
      end

      def handle_after_init = callback_handler.handle_after_init
    end
  end

  it "adds callback to given class" do
    expect(klass).to respond_to(:callbacky_after_init)
  end

  context "when callback name is given" do
    let(:test_klass) do
      Class.new(klass) do
        callbacky_after_init :handle_after_init
      end
    end

    it "calls given callback method by name" do
      spy = instance_double("CallbackHandler", handle_after_init: true)
      test_klass.new(callback_handler: spy)
      expect(spy).to have_received(:handle_after_init)
    end
  end

  context "when callback as a Proc is given" do
    let(:test_klass) do
      Class.new(klass) do
        callbacky_after_init ->(obj) { obj.handle_after_init }
      end
    end

    it "calls given Proc" do
      spy = instance_double("CallbackHandler", handle_after_init: true)
      test_klass.new(callback_handler: spy)
      expect(spy).to have_received(:handle_after_init)
    end
  end

  context "when callback as a block is given" do
    let(:test_klass) do
      Class.new(klass) do
        callbacky_after_init(&:handle_after_init)
      end
    end

    it "calls given block" do
      spy = instance_double("CallbackHandler", handle_after_init: true)
      test_klass.new(callback_handler: spy)
      expect(spy).to have_received(:handle_after_init)
    end
  end
end
