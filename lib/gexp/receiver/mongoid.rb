module Gexp
  class Receiver
    class Mongoid < self

      def receive
        Gexp::Mongoid::Transaction.with do |context|
          @stack.map do |command|
            command.perform
          end
        end
      end

    end
  end
end