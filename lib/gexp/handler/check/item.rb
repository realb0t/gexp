module Gexp
  class Handler
    class Check
      class Item < self

        def process(params, &block)

          results = params.map do |key, value|
            [
              key,
              value,
              @user.have_with_type?(key.to_s, value),
            ]
          end

          haves = results.map(&:last).all?

          if block_given?
            return block.call(results) if haves
          else
            unless haves
              view = results.map { |r| "#{r.first}_#{r.second}" }
              raise Exception.new("not_have_items-#{view.join(',')}") 
            end

            haves
          end

        end

      end
    end
  end
end