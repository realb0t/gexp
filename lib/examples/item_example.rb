class ItemExample

  include Mongoid::Document
  include Gexp::Item

  field :state, type: String, default: 'created'
  field :uid, type: String
  field :social_type_id, type: Integer

  field :x, type: Integer, default: 0
  field :y, type: Integer, default: 0

  scope :with_class_and_uid, lambda { |klass, uid, social_type_id| 
    where(_type: klass, uid: uid, social_type_id: social_type_id) 
  }

end
