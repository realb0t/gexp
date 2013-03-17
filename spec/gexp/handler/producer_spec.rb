# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Gexp::Handler::Producer do

  let(:objects) do
    {
      object:   Object.new,
      provider: Object.new,
      subject:  Object.new, 
    }
  end

  let(:emiter) do
    emiter = Gexp::Handler::Producer.new \
      params,
      type,
      objects
  end

  let(:handler) do
    handler = emiter.emit
  end

  before do
    emited_class.class.should be_a_kind_of Class
  end

  context "Caller" do

    let(:params) do
      [ :object, [ :arg1, :arg2, :arg3 ] ]
    end

    let(:emited_class) do
      Gexp::Handler::Caller
    end

    let(:type) do
    end

    it "build caller for self" do
      handler.should be_a_kind_of emited_class
    end

  end

  context "Other Handler" do

    let(:params) do
      [ :other, :object, { param: :value, other_param: :over_value } ]
    end

    let(:emited_class) do
      Gexp::Handler.const_get(handler_class).const_set :Other, (Class.new do
        def initialize(*args)
        end
      end)
    end

    context "Checker" do

      let(:handler_class) { :Check }
      let(:type) { :chekers }

      it "build caller for self" do
        handler.should be_a_kind_of emited_class
      end

    end

    context "Modifier" do

      let(:handler_class) { :Modify }
      let(:type) { :modifiers }

      it "build caller for self" do
        handler.should be_a_kind_of emited_class
      end

    end

  end

end
