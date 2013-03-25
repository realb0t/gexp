module Gexp
  class Handler
    # Базовый класс обработчиков

    attr_accessor :user, :object, :params, :objects

    # @params [Object] object - объект над котым производится обработка
    # @params [Hash] params
    # @params [Array] objects
    # @params [] 
    def initialize(object = nil, params = {}, objects = nil, full_params = nil)
      @object      = object
      @params      = params
      @objects     = objects
      @user        = (@objects || {})[:subject]
      @full_params = full_params
    end

    def process(params = nil)
      raise NotImplementedError.new \
        'Override process handler method'
    end

  end
end