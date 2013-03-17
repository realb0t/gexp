# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper.rb')

describe Gexp::Handler::Modify::Resources do

  before do
    @user   = UserExample.new
    @object = ItemExample.new

    subject.user   = @user
    subject.object = @object
  end

  context "#normilize" do

    it "с положительным параметром" do
      value = 100500
      subject.normalize(:undefined, value).should == value
    end

    it "с отрицательным параметром" do
      value = -3
      subject.normalize(:undefined, value).should be_zero
    end

  end

  context "#normalize_energy" do

    before { @max_energy = 20 }

    it "с отрицательным значением" do
      value = -1
      subject.normalize(:energy, value).should be_zero
    end

    context "Если не привышаем лимит" do
      before { stub(@user).max_energy.once { @max_energy } }

      it "с нормальным значением" do
        value = @max_energy / 2
        subject.normalize(:energy, value).should == value
      end

      it "с максимальным значением" do
        value = @max_energy
        subject.normalize(:energy, value).should == value
      end

    end

    it "со сверх большим значением" do
      stub(@user).max_energy.twice { @max_energy }
      value = @max_energy + 1
      subject.normalize(:energy, value).should == @max_energy
    end

  end

  context "Изменение ресурсов" do

    it "Энергия должна быть начисленна" do
      @user.energy = 5
      subject.process({ energy: 5 })
      @user.energy.should == 10
    end

    it "Энергия должна списываться" do
      @user.energy = 10 
      subject.process({ energy: -5 })
      @user.energy.should == 5
    end

    it "Энергия должна списываться, а экспа начисляться" do
      @user.energy = 10 
      @user.exp = 10 
      subject.process({ energy: -5, exp: 5 })
      @user.energy.should == 5
      @user.exp.should == 15
    end

    it "Если ресурса не хватает, полностью прерываем транзакцию" do
      @user.energy = 10
      @user.exp = 10

      lambda {
        subject.process({ exp: 5, energy: -11 })
      }.should raise_error /out_of_resource\-energy/

      @user.energy.should == 10
      @user.exp.should == 10
    end

  end

end
