class UserExample
  include Mongoid::Document

  field :energy, type: Integer
  field :exp, type: Integer
  field :exp_level, type: Integer

  def max_energy
    [ 10, 40, 50, 60, 80, 90, 100][self.exp_level || 0]
  end

  def after_change!(param)
  end
end