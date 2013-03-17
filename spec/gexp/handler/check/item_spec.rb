# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper.rb')

describe Gexp::Handler::Check::Item do

  before do
    @user   = UserExample.new
    @object = Object.new

    subject.user   = @user
    subject.object = @object
  end

  it "Если имеем объект и не передали блок" do
    mock(@user).have_with_type?('item.stage.house', 1) { true }
    result = subject.process({ 'item.stage.house' => 1 })
    result.should be_true
  end

  it "Если имеем объект передали блок" do
    mock(@user).have_with_type?('item.stage.house', 1) { true }
    result = false
    subject.process({ 'item.stage.house' => 1 }) {
      result = true
    }.should be_true
    result.should be_true
  end

  it "Если не имеем объект и не передали блок" do
    mock(@user).have_with_type?('item.stage.house', 1) { false }
    lambda {
      subject.process({ 'item.stage.house' => 1 })
    }.should raise_error /not_have_items/
  end

  it "Если имеем объект передали блок" do
    mock(@user).have_with_type?('item.stage.house', 1) { false }
    result = false
    subject.process({ 'item.stage.house' => 1 }) {
      result = true
    }.should be_nil
    result.should be_false
  end

end