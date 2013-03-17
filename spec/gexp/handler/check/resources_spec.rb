# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'spec_helper.rb')

describe Gexp::Handler::Check::Resources do

  before do
    @user   = User.new
    @object = Object.new

    subject.user   = @user
    subject.object = @object
  end

  context "#access_resource" do

    before {
      pending "Еще не проверялись"
    }

    it "Возвращение значения ресурса" do
      @user.energy = 5
      energy = subject.chain_resource('energy', @user)
      energy.should == 5
    end

    it "Возвращение значения вложенного ресурса" do
      @user.resources.resource_1 = 5
      resource_1 = subject.chain_resource('resources.resource_1', @user)
      resource_1.resource_1.should == 5
    end

    it "Назначение значения ресурса" do
      @user.energy = 5
      subject.chain_resource('energy=', @user, 6)
      @user.energy.should == 6
    end

    it "Назначение значения ыложенного ресурса" do
      @user.resources.resource_1 = 5
      subject.chain_resource('resources.resource_1=', @user, 6)
      @user.resources.resource_1.should == 6
    end

  end

  it "Если у пользователя есть ресурс" do
    @user.energy = 5
    subject.process(energy: 5).should be_true
  end

  it "Если у пользователя есть ресурсы" do
    @user.energy = 5
    @user.exp = 5
    subject.process(energy: 5, exp: 3).should be_true
  end

  it "Если у пользователя нет ресурсов" do
    @user.energy = 5
    @user.exp = 5
    lambda {
      subject.process(energy: 6, exp: 7).should be_false
    }.should raise_error /out_of_resources\-energy,exp/
  end

  it "Успешная проверка ресурсов с блоком" do
    @user.energy = 5
    @user.exp = 5
    prob = false
    subject.process(energy: 5, exp: 3) { prob = true }
    prob.should be_true
  end

  it "Не успешная проверка ресурсов с блоком" do
    @user.energy = 0
    @user.exp = 5
    prob = false
    subject.process(energy: 5, exp: 3) { prob = true }
    prob.should be_false
  end

end