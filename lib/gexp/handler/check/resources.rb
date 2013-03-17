module Gexp
  class Handler
    class Check
      class Resources < self

        def chain_resource(resource, object = nil, params = nil)
          if resource.is_a?(Array) # Если цепочка как массив
            curr_field = resource.shift
            if object # Если уже был получен результат
              if resource.count.zero? # Если последний метод в цепочке
                if params
                  # Если сеттер
                  object.send(curr_field, params) # last
                else
                  # Если геттер
                  object.send(curr_field)
                end
              else # Если не последний метод в цепочке
                access_resource_get(resource, object.send(curr_field), params)
              end
            else # Если метод еще не было вызовов
              access_resource_get(resource, @user.send(curr_field), params)
            end
          else # Если цепочка как строка
            access_resource_get(resource.split('.'), object, params)
          end
        end

        def process(params, &block)

          compairs = params.map do |resource, value|
            if @user.respond_to?(resource)
              current = @user.send(resource.to_s.split('.').last)
              [ current >= value, current, value, resource ]
            end
          end

          compairs.compact!
          results = compairs.map(&:first).all?

          if block_given?
            block.call(compairs) if results
          else
            unless results
              resources = compairs.reject(&:first).map(&:fourth)
              raise Exception.new("out_of_resources-#{resources.join(',')}") 
            end

            results
          end
        end

      end
    end
  end
end
