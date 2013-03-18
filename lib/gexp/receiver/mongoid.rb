module Gexp
  class Receiver
    class Mongoid < self

      def receive
        @stack.map do |command|
          Gexp::Mongoid::Transaction.with do |context|
            command.perform
          end
        end
      end
      
    end
  end
end