module Gexp
  class Handler

    # Инкапсулирцует логику по созданию 
    # объектов-обработчиков команд на основании
    # выражения-генератора полученного Builder'ом
    # из конфигурационного файл объекта
    class Producer

      def self.namespaces
        {
          chekers: Gexp::Handler::Check,
          modifiers: Gexp::Handler::Modify,
        }
      end

      #
      #
      # params - handler params { klass, object, args }
      # type - chekers|modifiers # TODO: избавиться от этого параметра
      # objects - { object: <...>, subject: <...>, provider: <...>  }
      def initialize(params, type = nil, objects = {})
        @params  = params
        @type    = type
        @objects = objects

        if !for_klass? && !for_caller?
          raise 'Can\'t define handler class'
        end
      end

      def emit
        args = @params.clone

        if for_klass?
          superclass = self.class.namespaces[@type]
          subclass   = args.shift.to_s.classify
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

      def for_klass?
        @params.size == 3
      end

      def for_caller?
        @params.size == 2
      end

    end
  end
end