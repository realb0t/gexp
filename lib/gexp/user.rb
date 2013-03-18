module Gexp
  module User

    def after_change!(param)
      raise NotImplementedError.new
    end

  end
end