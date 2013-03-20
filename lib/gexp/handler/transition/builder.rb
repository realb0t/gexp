module Gexp
  class Handler
    class Transition

      # Возвращает обработчики 
      # в зависимости от перехода FSM (StateMachine)
      class Builder < self

        def events(last_key)
          event = self.config.to_hash[:states][:events][@transition.event.to_sym]
          (event || {})[last_key] || []
        end

        def transitions(last_key)
          from        = self.transition.from_name
          to          = self.transition.to_name
          from_branch = self.config.to_hash[:states][:transitions][from] || {}
          
          (from_branch[to] || {})[last_key] || []
        end

        def checkers
          events(:check) + transitions(:check)
        end

        def modifiers
          events(:modify) + transitions(:modify)
        end

      end

    end
  end
end