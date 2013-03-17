module Gexp
  module StateDefinition
    module StateMachine

      extend ActiveSupport::Concern

      included do
      end

      module ClassMethods

        def define_state_by(state_configs)
          sm            = state_configs
          state_aliases = [ :all, :any ]

          self.instance_eval do
            state_machine initial: sm[:initial] do

              # Внешний хук от Handlers
              around_transition :around_handlers

              # State Machine Context
              smc = self

              # State definition
              sm[:states].each do |name, methods|
                smc.state name do
                  (methods || []).each do |method|
                    self.send(method)
                  end
                end
              end

              # Events definition
              sm[:events].each do |name, transitions|

                smc.event name do

                  transitions.each do |opts|
                    opts[:if] ||= []
                    opts[:do] ||= []

                    from = opts[:from] || :any
                    to   = opts[:to]   || :any

                    from = send(from) if state_aliases.include?(from)
                    to   = send(to) if state_aliases.include?(to)

                    transition from => to, :if => lambda { |item|
                      opts[:if].map { |method|
                        item.send(method)
                      }.all?
                    }
                    #, :do => lambda { |item|
                    #  opts[:do].each { |method|
                    #    item.send(method)
                    #  }
                    #}
                  end

                end
              end

              # Before/After transition
              [ :before, :after ].each do |name|

                (sm[name] || []).each do |opts|

                  from = opts[:from] || :any
                  to   = opts[:to]   || :any

                  from = send(from) if state_aliases.include?(from)
                  to   = send(to) if state_aliases.include?(to)

                  smc.send(:"#{name}_transition", from => to, :do => lambda { |item|
                    opts[:do].each do |method|
                      item.send(method)
                    end
                  })

                end
              end

            end
          end
        end
      end
    end
  end
end