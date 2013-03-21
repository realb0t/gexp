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

  it "" do
    mock(subject).check_handlers(anything)
    mock(subject).before_event(anything)
    mock(subject).after_event(anything)
    mock(subject).modify_handlers(anything) { |transition|
      #require 'pry'
      #binding.pry
    }

    receiver.receive
  end

end