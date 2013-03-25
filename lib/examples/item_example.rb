require 'configuration'

Configuration.for(:item_example) do
  states {
    initial :created
    states { # TODO!: Переименовать в transitions
             # для этого нужны изменения в Gexp::Handler::Transition::Builder
      created {
        prebuilded {
          modify [
            [ :resources, :subject, { wood: -5, energy: -1 } ],
          ]
        }
      }
      prebuilded {}
      postbuild {}
      builded {}
    }

    events {
      pick [
        { from: :created, to: :prebuilded },
        { from: :prebuilded, to: :postbuilded },
        { from: :postbuilded, to: :builded },
        { from: :builded, to: :builded },
      ]
    }
  }
end

class ItemExample

  include Mongoid::Document
  include Gexp::Item
  include Gexp::Object

  field :state, type: String, default: 'created'
  field :uid, type: String
  field :social_type_id, type: Integer

  field :x, type: Integer, default: 0
  field :y, type: Integer, default: 0

  scope :with_class_and_uid, lambda { |klass, uid, social_type_id| 
    where(_type: klass, uid: uid, social_type_id: social_type_id) 
  }

end
