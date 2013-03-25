module Gexp
  class Handler
    class Transition

      # Возвращает обработчики 
      # в зависимости от перехода FSM (StateMachine)
      class Builder < self

        # XXX: метод не используется
        # тк определение событий хранит
        # только информацию по переходам
        def events(last_key)
          event = self.config.to_hash[:states][:events][@transition.event.to_sym]
          (event || {})[last_key] || []
        end

        # Возвращает конфиги для создания обработчиков
        #
        # @params [Symbol] last_key - [ :check | :modify ]
        # @returns [Array]
        def conf_handlers(last_key)
          from        = self.transition.from_name
          to          = self.transition.to_name
          from_branch = self.config.to_hash[:states][:states][from] || {}

          configs     = (from_branch[to] || {})[last_key] || []
        end

        def transitions(last_key)
          conf = conf_handlers(last_key)
          type = last_key == :check ? :checkers : :modifiers

          observers = conf.map do |params|

            producer = Gexp::Handler::Producer.new(params, type, { 
              object: self.object,
              subject: self.subject,
              provider: self.provider,
            })

            producer.emit
          end

          observers
        end

        def checkers
          transitions(:check)
        end

        def modifiers
          transitions(:modify)
        end

      end

    end
  end
end