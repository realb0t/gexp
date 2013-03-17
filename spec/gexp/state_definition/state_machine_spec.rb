# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper.rb')

describe Gexp::StateDefinition::StateMachine do

  before do
    SubjectClass = Class.new do
      include Gexp::StateDefinition::StateMachine
    end
  end

  it "should be definition states" do
    SubjectClass.instance_eval do
      self.define_state_by({
        states:  { first: nil, second: nil, last: nil },
        initial: :created,
        events:  {
          do_first: [{
            from: :created,
            to:   :first,
          }],
          do_second: [{
            from: :first,
            to:   :second,
          }],
          do_last: [{
            from: :second,
            to:   :last,
          }]
        },
        after:   [],
        before:  [],
      })
    end

    states = SubjectClass.state_machines[:state].states.map(&:name)
    states.should == [ :created, :first, :second, :last ]

    events = SubjectClass.state_machines[:state].events

    events.map(&:name).should == [ :do_first, :do_second, :do_last ]

    events[:do_first].branches[0].state_requirements[0][:from].values.should == [:created]
    events[:do_second].branches[0].state_requirements[0][:from].values.should == [:first]

  end

end