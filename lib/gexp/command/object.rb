module Gexp
  class Command
    class Object < self

      attr_accessor :event # TODO: only getter
      attr_accessor :object

      def initialize(params = {})
        super
        @event = @params[:event]
        self.load_object
      end

      def perform
        self.activate!
        @object.send(self.event)
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