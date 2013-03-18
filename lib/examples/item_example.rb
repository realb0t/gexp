class ItemExample
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

  include Mongoid::Document

  field :state, type: String, default: 'created'
  field :uid, type: String
  field :social_type_id, type: Integer

  field :x, type: Integer, default: 0
  field :y, type: Integer, default: 0

  scope :with_class_and_uid, lambda { |klass, uid, social_type_id| 
    where(_type: klass, uid: uid, social_type_id: social_type_id) 
  }

  # TODO: по возможности переделать на Mongoid::Observer или скрыть из конфига
  def around_handlers(transition, &block)
    self.check_handlers(transition)
    self.before_event(transition)
    #require 'pry'
    #binding.pry
    block.call
    self.after_event(transition)
    self.modify_handlers(transition)
  rescue => e
    raise
  end

  def before_event(transition)
  end

  def after_event(transition)
  end

  def check_handlers(transition)
  end

  def modify_handlers(transition)
  end

end
