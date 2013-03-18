module Gexp
  class Receiver
    class Example < self

      def receive
        @stack.map do |hash, command|
          # Start transaction
          command.perform
          # finish transaction
        end
      end
      
    end
  end
end