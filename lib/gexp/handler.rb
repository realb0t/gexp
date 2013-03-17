module Gexp
  class Handler
    # Базовый класс обработчиков

    attr_accessor :user, :object

    #
    #
    # object - объект над котым производится обработка
    #
    #
    def initialize(object = nil, params = {}, objects = nil, full_params = nil)
      @object      = object
      @params      = params
      @objects     = objects
      @user        = (@objects || {})[:self]
      @full_params = full_params
    end

    def process(params = nil)
      raise 'Override process handler method'
    end

  end
end