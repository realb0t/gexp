module Gexp
  class Handler
    class Transition

      attr_accessor :transition, :config, :object, :subject, :provider

      def self.namespaces
        @namespaces ||= {
          checkers:  Gexp::Handler::Check,
          modifiers: Gexp::Handler::Modify,
        }
      end

      # transition - объект транзакции от стейт машины
      # object     - объект у которого вызывается событие стейтмашины
      # subject    - объект кто вызывает событие (всегда User)
      # provider   - объект которому принадлежит object (иногда User иногда Friend)
      #
      # Выбор конечного объекта определяется конфигом object
      def initialize(transition, object = nil, subject = nil, provider = nil)
        @transition = transition

        @object     = object
        @subject    = subject
        @provider   = provider

        @config     = @object.config
      end

      def produce(params, type)
        producer = Gexp::Handler::Producer.new params, type
        producer.emit
      end

      def handlers(type = nil)
        type = :checkers
        (self.send(type) || []).map do |handler_params|
          self.produce(handler_params, type)
        end
      end

    end
  end
end