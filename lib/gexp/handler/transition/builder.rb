module Gexp
  class Handler
    class Transition

      # Возвращает обработчики 
      # в зависимости от перехода FSM (StateMachine)
      class Builder < self

        def events(last_key)
          event = @config[:events][@transition.event]
          (event || {})[last_key] || []
        end

        def transitions(last_key)
          from = @transition.from_name
          to = @transition.to_name
          from_branch = @config[:transitions][from] || {}
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