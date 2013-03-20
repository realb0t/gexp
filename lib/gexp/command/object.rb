module Gexp
  class Command

    # Объектная команда
    #
    # Команда выполняющаяся над объектами
    # игрового мира.
    #
    # Выполняет событие FSM у объекта описанное
    # в параметрах.
    class Object < self

      def initialize(params = {})
        super
        @event = @params[:event]
        self.load_object
      end

      # Выполнение команды
      def perform
        self.activate!
        @object.send(self.event, self)
        self.complete!
      rescue => e
        self.errors << e
        self.failure!
      end

      protected

        def load_object
          if @params[:objects]
            label   = @params[:objects].keys.first
            id      = @params[:objects].values.first
            @object = Gexp.label_to_class(label).find(id)
          else
            raise "Can't find object params"
          end
        end

    end
  end
end