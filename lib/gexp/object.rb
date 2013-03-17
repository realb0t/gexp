require File.join('gexp', 'state_definition')
require File.join('gexp', 'state_definition', 'state_machine')

module Gexp
  module Object
    extend ActiveSupport::Concern
    include ::Gexp::StateDefinition::StateMachine

    def self.included(base)
      @config_name = base.name.gsub('::', '.').underscore
      @end_class_name = base.name.split('::').last

      @config = Configuration.for(@config_name)

      base.instance_variable_set("@config_name", @config_name)
      base.instance_variable_set("@config", @config)

      if @config.respond_to? :states
        base.define_state_by @config.states.to_hash
      end
    end

    def config
      self.class.config
    end

    module ClassMethods

      def config_name
        @config_name
      end

      def config
        @config
      end
      
    end
  end
end
