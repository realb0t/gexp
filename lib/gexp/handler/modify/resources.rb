# encoding: utf-8

# Изменяет количество ресурсов у пользователя
module Gexp
  class Handler
    class Modify
      class Resources < self

        class Exception < StandardError; end

        # Нормализация энергии
        def normalize_energy(value)
          if value > @user.max_energy
            @user.max_energy 
          else
            value
          end
        end

        # Нормализация неопределенного ресурса
        def normalize_undefined(value)
          value
        end

        # Нормальлизация значений ресурсов
        def normalize(resource, value)
          return 0 if value < 0
          method_name = "normalize_#{resource}"
          
          if self.respond_to?(method_name)
            self.send(method_name, value) 
          else
            self.normalize_undefined value
          end
        end

        # Применение изменений к ОВ
        def apply_changes
          @changes.each do |resource, value| 
            @user.send("#{resource}=", value[:after])
          end
        end

        # Применимы изменения к объекту в момент обработки
        def ontime_apply?
          true # TODO: сделать выяснения что изменения применимы
        end

        def process(params = {}, &block)
          @changes = {}
          @params = params if @params.empty?
          @params = @params.first if @params.is_a?(Array)
          @params.each do |resource, value|
            if @user.respond_to?(resource.to_sym)

              if @user.send(resource) + value < 0
                raise Exception.new("out_of_resource-#{resource}")
              end

              before_value = @user.send(resource)
              new_value    = before_value + value
              norm_value   = self.normalize(resource, new_value)

              @changes[resource] = {
                before: before_value,
                delta:  value,
                after:  norm_value,
              }
            end
          end

          self.apply_changes if self.ontime_apply?
          @user.after_change!(@changes)

          return block.call(@user) if block_given?
          @user
        end

      end
    end
  end
end
