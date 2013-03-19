module Gexp
  class Receiver
    class Example < self

      def receive
        # Start transaction
        @stack.map do |hash, command|
          command.perform
        end
        # finish transaction
      end
      
    end
  end
end