# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Gexp::Item do

  let(:subject) { ItemExample.new }
  let(:receiver_class) { Gexp::Receiver::Example }
  let(:user) { UserExample.new }
  let(:request) do
    HashWithIndifferentAccess.new({ 
      :params => {
        :sended_at => 123456789.012,
        :create_at => 123456789.012,
        :commands => [{ 
          # У себя на карте
          :event      => :pick, 
          :stage      => { x: 100, y: 200 },
          :rewards    => { energy: -1, exp: 5 },
          :timestamp  => 123456789.012,
          :objects    => { 'item_example' => '55a55' },
          :transition => { :builded => :builded },
          :seed       => 532434234,
        }]
      }
    })
  end

  let(:receiver) { receiver_class.new(user, request) }

  before do
    stub(ItemExample).find('55a55') { subject }
  end

  it { subject.should be_created }

  it "если ресурсы в наличии" do
    user.energy = 5
    user.wood   = 25
    receiver.receive
    subject.reload
    subject.should be_prebuilded
    user.energy.should be 5 - 1
    user.wood.should be 25 - 5
  end

  it "если нехватает энергии" do
    user.energy = 0
    user.wood   = 25
    lambda { receiver.receive }.should raise_error Regexp.new("out_of_resource-energy")
    subject.reload
    user.energy.should be 0
    user.wood.should be 25
  end

  it "если нехватает дерева" do
    user.energy = 5
    user.wood   = 4
    subject.should be_created
    lambda { receiver.receive }.should raise_error Regexp.new("out_of_resource-wood")
    subject.reload
    user.energy.should be 5
    user.wood.should be 4
  end

end