# frozen_string_literal: true

RSpec.describe Callbacky do
  let(:base_class) do
    Class.new do
      include Callbacky
    end
  end

  describe ".callbacky_callbacks" do
    subject(:callbacks) { klass.callbacky_callbacks }

    context "when no callbacks are defined" do
      let(:klass) { Class.new(base_class) }

      it "returns an empty hash" do
        expect(callbacks).to eq({})
      end
    end

    shared_examples "a single lifecycle event" do |lifecycle|
      context "with one callback method" do
        let(:klass) do
          Class.new(base_class) do
            callbacky lifecycle, :init, :step_one
          end
        end

        it "stores the callback correctly" do
          expect(callbacks).to eq(init: { lifecycle => [:step_one] })
        end
      end

      context "with multiple callbacks in one definition" do
        let(:klass) do
          Class.new(base_class) do
            callbacky lifecycle, :init, :step_one, :step_two
          end
        end

        it "stores all callback methods" do
          expect(callbacks).to eq(init: { lifecycle => %i[step_one step_two] })
        end
      end

      context "with multiple callbacky calls for the same event" do
        let(:klass) do
          Class.new(base_class) do
            callbacky lifecycle, :init, :step_one
            callbacky lifecycle, :init, :step_two
          end
        end

        it "merges callbacks from multiple definitions" do
          expect(callbacks).to eq(init: { lifecycle => %i[step_one step_two] })
        end
      end

      context "with duplicate callbacks" do
        let(:klass) do
          Class.new(base_class) do
            callbacky lifecycle, :init, :step_one
            callbacky lifecycle, :init, :step_one
          end
        end

        it "stores only unique callbacks" do
          expect(callbacks).to eq(init: { lifecycle => [:step_one] })
        end
      end
    end

    include_examples "a single lifecycle event", :before
    include_examples "a single lifecycle event", :after
  end

  describe "callback execution" do
    let(:spy) { instance_double("CallbackHandler", handle_1: true, handle_2: true) }

    context "with only methods as callbacks" do
      let(:klass) do
        Class.new(base_class) do
          callbacky :before, :init, :before_1, :before_2
          callbacky :after, :init, :after_1, :after_2

          attr_reader :callback_handler

          def initialize(callback_handler:)
            @callback_handler = callback_handler
            callbacky_init {}
          end

          private

          def before_1 = callback_handler.handle_1
          def before_2 = callback_handler.handle_2
          def after_1  = callback_handler.handle_1
          def after_2  = callback_handler.handle_2
        end
      end

      it "calls all before and after methods" do
        klass.new(callback_handler: spy)
        expect(spy).to have_received(:handle_1).twice
        expect(spy).to have_received(:handle_2).twice
      end
    end

    context "with method + block callbacks" do
      let(:klass) do
        Class.new(base_class) do
          callbacky :before, :init, :before_1 do |obj|
            obj.callback_handler.handle_2
          end

          callbacky :after, :init, :after_1 do |obj|
            obj.callback_handler.handle_2
          end

          attr_reader :callback_handler

          def initialize(callback_handler:)
            @callback_handler = callback_handler
            callbacky_init {}
          end

          private

          def before_1 = callback_handler.handle_1
          def after_1  = callback_handler.handle_1
        end
      end

      it "calls both method and block callbacks" do
        klass.new(callback_handler: spy)
        expect(spy).to have_received(:handle_1).twice
        expect(spy).to have_received(:handle_2).twice
      end
    end

    context "when yielding to block between lifecycle events" do
      it "executes the yielded block between callbacks" do
        klass = Class.new(base_class) do
          attr_accessor :results

          callbacky :before, :init do |it|
            it.results << :before
          end

          callbacky :after, :init do |it|
            it.results << :after
          end

          def initialize()
            @results = []
            callbacky_init { @results << :main }
          end
        end

        obj = klass.new
        expect(obj.results).to eq([:before, :main, :after])
      end
    end
  end
end
