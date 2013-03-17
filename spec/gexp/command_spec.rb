# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Gexp::Command do

  context "Базовый функционал команды" do

    before do
      @user    = Fabricate(:user)
      @request = HashWithIndifferentAccess.new({
        :params => {
                :event => :command_event, 
                :timestamp => 1234567890.123,
                :seed => 123321123 }
      })

      @user = Object.new
      @context  = Object.new

      lambda {
        @command = Gexp::Command.new @request[:params]
        @command.context = @context
      }.should_not raise_error
    end


    it "Команде должен выставлятся контекст" do
      @command.context.should == @context
    end

    it "В команду должны должны копироваться параметры" do
      @command.params.should == @request[:params]
    end

    it "Команда должны реализовывать StateMachine (положительный сценарий)" do
      @command.should be_new
      @command.activate!
      @command.should be_active
      @command.complete!
      @command.should be_done
    end

    it "Команда должны реализовывать StateMachine (отрицательный сценарий)" do
      @command.should be_new
      @command.activate!
      @command.should be_active
      @command.failure!
      @command.should be_failed
    end

    it "Базовую команду нельзя выполнить" do
      lambda {
        @command.perform
      }.should raise_error /Not defined perform method/
    end

  end

end