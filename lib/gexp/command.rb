# encoding: utf-8
require 'state_machine/core'

module Gexp
  class Command

    extend StateMachine::MacroMethods

    attr_accessor :errors
    attr_accessor :context
    attr_accessor :params

    state_machine :initial => :new do
      state :active
      state :done
      state :failed

      event :activate do
        transition :new => :active
      end

      event :complete do
        transition :active => :done
      end

      event :failure do
        transition :active => :failed
      end
    end

    def initialize(params = {})
      @params  = params.dup
      @errors  = []
      
      super() # Инициализация StateMachine
    end

    def hash
      # TODO: Заменить на BSON:ObjectId
      [
        @params[:timestamp],
        @params[:event],
        @params[:seed],
      ].join('_')
    end

    def perform
      self.activate!
      self.failure!
      raise 'Not defined perform method'
    end

  end
end