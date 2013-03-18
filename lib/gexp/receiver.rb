module Gexp
  class Receiver

    class << self

      def current=(receiver)
        @current = receiver
      end

      def current
        @receiver ||= self.new
      end

    end

    def initialize(user, request)
      @user    = user
      @request = request

      @stack = Gexp::Command::Stack.new \
        @user, @request
    end

    def receive
      raise NotImplementedError.new \
        "Abstract receiver class"
    end

  end
end