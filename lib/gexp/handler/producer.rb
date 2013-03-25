module Gexp
  class Handler

    # Инкапсулирцует логику по созданию 
    # объектов-обработчиков команд на основании
    # выражения-генератора полученного Builder'ом
    # из конфигурационного файл объекта
    class Producer

      class << self

        # @return [Hash] - хеш классов обработчиков 
        def namespaces
          {
            chekers:   Gexp::Handler::Check,
            modifiers: Gexp::Handler::Modify,
          }
        end

      end

      # @params [Hash] params  - handler params { klass, object, args }
      # @params [String] type  - chekers|modifiers # TODO: избавиться от этого параметра
      # @params [Hash] objects - { object: <...>, subject: <...>, provider: <...>  }
      def initialize(params, type = nil, objects = {})
        @params  = params
        @type    = type
        @objects = objects

        if !for_klass? && !for_caller?
          raise 'Can\'t define handler class'
        end
      end

      # Создает и возвращает класс обработчика
      #
      # @return [Gexp::Handler]
      def emit
        args = @params.clone

        if for_klass?
          superclass = self.class.namespaces[@type]
          subclass   = args.shift.to_s.humanize

          # TODO: Сделать проверку существования класса
          klass      = superclass.const_get(subclass)
        else
          klass  = Gexp::Handler::Caller
        end

        obj_key = args.shift
        object  = @objects[obj_key]
        params  = args
        handler = klass.new(object, params, @objects, @params)
      end

      protected

        # Параметры под класс
        #
        # @return [Boolean]
        def for_klass?
          @params.size == 3
        end

        # Параметры под коллер
        #
        # @return [Boolean]
        def for_caller?
          @params.size == 2
        end

    end
  end
end