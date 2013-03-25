class UserExample

  include Mongoid::Document
  include Gexp::User

  field :energy, type: Integer, default: 0
  field :exp, type: Integer, default: 0
  field :exp_level, type: Integer, default: 0
  field :wood, type: Integer, default: 0

  def max_energy
    [ 10, 40, 50, 60, 80, 90, 100][self.exp_level || 0]
  end

  def after_change!(param)
  end

end