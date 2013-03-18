# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Gexp::Receiver do

  let(:receiver_class) { Gexp::Receiver::Example }
  let(:user) { UserExample.new }
  let(:item_id) { 1 }
  let(:item) { ItemExample.new }
  let(:request) do
    HashWithIndifferentAccess.new({ 
      :params => {
        :sended_at => 123456789.012,
        :create_at => 123456789.012,
        :commands   => [{ 
          # У себя на карте
          :event      => :pick, 
          :stage      => { x: 100, y: 200 },
          :rewards    => { energy: -1, exp: 5 },
          :timestamp  => 123456789.012,
          :objects    => { 'item_example' => item_id },
          :transition => { :builded => :builded },
          :seed       => 532434234,
        }]
      }
    })
  end

  let(:subject) do
    receiver_class.new(user, request)
  end

  before do
    stub(ItemExample).find(item_id) { item }
  end

  context "Успешная обработка комманды" do
  
    it "должна пройти без ошибок" do
      #lambda {
        subject.receive
      #}.should_not raise_error
    end

  end


end