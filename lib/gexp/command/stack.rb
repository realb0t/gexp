module Gexp
  class Command

    # Стек комманд.
    #
    # Принимает реквест и разбивает его
    # батч на команды
    class Stack

      include Enumerable

      attr_accessor :user, :request

      def initialize(user, request)
        @user     = user
        @request  = request
        @commands = {} # для ruby 1.9.x иначе OrderedHash
        self.fill()
      end

      # Фабрика команд по их параметрам
      def build_command(command_param = {})
        # XXX: пока один поддерживаемый тип комманд
        # TODO: Расширять типы команд отсюда,
        # возможно нужен конфиг соотвествия
        # Тип События - Тип команды
        Gexp::Command::Object.new(command_param)
      end

      # Заполняет хеш команд по реквесту
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

      # Просто перебор команд для Enumerable
      def each(&block)
        @commands.each(&block)
      end

      protected

        # Добавляет команду в общий хеш
        # и задает контекст
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