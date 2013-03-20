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
      transition = Gexp::Handler::Transition.new(transition)

      self.check_handlers(transition)
      self.before_event(transition)
      block.call # выполнение самого перехода
      self.after_event(transition)
      self.modify_handlers(transition)
    rescue => e
      raise unless self.on_error(e)
    end

    def on_error(exception)
      # TODO: Сделать обработку ошибок перехода
    end

    def before_event(transition)
      # TODO: сделать обработку события
    end

    def after_event(transition)
      # TODO: сделать обработку события
    end

    def check_handlers(transition)
      # TODO: Сделать обработку чекеров
    end

    def modify_handlers(transition)
      # TODO: Сделать обработку модифаеров
    end

  end
end