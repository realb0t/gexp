module Gexp
  class Command
    class Stack

      include Enumerable

      attr_accessor :user, :request

      def initialize(user, request)
        @user     = user
        @request  = request
        @commands = {} # for ruby 1.9.x
        self.fill()
      end

      def build_command(command_param = {})
        Gexp::Command::Object.new(command_param)
      end

      def fill(request = nil)
        request ||= @request
        @commands = {}

        opts = request[:params][:commands] || []
        opts.each do |command_param|
          self.add self.build_command(command_param)
        end
      end

      def size
        @commands.size
      end

      def each(&block)
        @commands.each(&block)
      end

      protected

        def add(command)
          command.context = self
          if @commands[command.hash].present?
            raise "Command with hash #{command.hash} be exist"
          end
          @commands[command.hash] = command
        end

    end
  end
end