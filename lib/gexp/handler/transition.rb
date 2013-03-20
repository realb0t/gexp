module Gexp
  class Handler
    class Transition

      attr_accessor :transition, :object, :subject, :provider

      def self.namespaces
        @namespaces ||= {
          checkers:  Gexp::Handler::Check,
          modifiers: Gexp::Handler::Modify,
        }
      end

      # @params [StateMachine::Transaction] transition - объект транзакции от стейт машины
      # @params [Item]                      object     - объект у которого вызывается событие стейтмашины
      # @params [User]                      subject    - объект кто вызывает событие (всегда User)
      # @params [User]                      provider   - объект которому принадлежит object (иногда User иногда Friend)
      #
      # @note Выбор конечного объекта определяется конфигом object
      #
      def initialize(transition, object = nil, subject = nil, provider = nil)
        @transition = transition
        actor       = @transition.args.first

        unless self.actor_support?(actor)
          raise "Unsupported actor type #{@actor.class.name}"
        else
          @actor = actor
        end
      end

      def object
        @object   ||= @actor.object
      end

      def subject
        @subject  ||= @actor.subject
      end

      def provider
        @provider ||= @actor.provider
      end

      def config
        @config   ||= self.object.config
      end

      def actor_support?(actor)
        !actor.nil?
      end

      # Создает объект обработчика
      #
      # @params [Gexp::Handler]
      def produce(params, type)
        producer = Gexp::Handler::Producer.new params, type
        producer.emit
      end

      # Возвращает массив обработчиков
      #
      # @return [Array(Gexp::Handler)]
      def handlers(type = nil)
        type ||= :checkers
        (self.send(type) || []).map do |handler_params|
          self.produce(handler_params, type)
        end
      end

    end
  end
end