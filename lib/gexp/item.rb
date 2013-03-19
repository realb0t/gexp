module Gexp

  module Item

    def self.included(base)
      base.instance_eval do
        class << self
          def inherited(sub)
            sub.instance_eval do
              include Gexp::Object
            end
          end

          def register
            @register ||= {}

            if @register.empty?
              register = Configuration.for 'register'
              register.keys.each do |key|
                @register[key] = Configuration.for(key).to_hash
              end
            end

            @register
          end

          def reload_register!
            @register = {}
          end

        end
      end
    end

    def around_handlers(transition, &block)
      # объект команды (как параметр к событию)
      actor = transition.args.first
      
      unless actor_support?(actor)
        raise "Unsupported actor #{actor.class.name}"
      end

      self.check_handlers(actor)
      self.before_event(actor)
      block.call # выполнение самого перехода
      self.after_event(actor)
      self.modify_handlers(actor)
    rescue => e
      raise unless self.on_error(e)
    end

    def actor_support?(actor)
      !actor.nil?
    end

    def on_error(exception)
      # TODO: Сделать обработку ошибок перехода
    end

    def before_event(actor)
      # TODO: сделать обработку события
    end

    def after_event(actor)
      # TODO: сделать обработку события
    end

    def check_handlers(actor)
      # TODO: Сделать обработку чекеров
    end

    def modify_handlers(actor)
      # TODO: Сделать обработку модифаеров
    end

  end
end