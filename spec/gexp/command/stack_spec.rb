# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Gexp::Command::Stack do

  context "#each" do

    let(:request) { 
      HashWithIndifferentAccess.new({ 
        :params => {
          :sended_at => 123456789.012,
          :create_at => 123456789.012,
          :commands => [
            { # У себя на карте
              :event => :pick, 
              :stage => { x: 100, y: 200 },
              :rewards => { energy: -1, exp: 5 },
              :timestamp => 123456789.012,
              :objects => { 'item_example' => '50c12939584aa5488a000001' },
              :transition => { :builded => :builded },
              :timestamp => 123456789.010,
              :seed => 532434234,
            }, { # У друга на карте
              :event => :pick, 
              :stage => { x: 100, y: 200 },
              :uid => '<friend_uid>',
              :rewards => { energy: -1, exp: 5 },
              :timestamp => 123456789.012,
              :objects => { 'item_example' => '50c12939584aa5488a000002' },
              :transition => { :builded => :builded },
              :timestamp => 123456789.011,
              :seed => 532434234,
            }, { # создание здания
              :event => :create,
              :stage => { x: 100, y: 200 },
              :objects => { 'item_example' => '50c12939584aa5488a000003' },
              :reward => { gold: -100 },
              :timestamp => 123456789.012,
              :seed => 532434234,
            }, { # создание контракта
              :event => :pick,
              :stage => { x: 100, y: 200 },
              :objects => { 'item_example' => '50c12939584aa5488a000004' },
              :timestamp => 123456789.013,
              :seed => 532412334,
            },
          ]
        }
      })
    }

    let(:item1) { ItemExample.new }
    let(:item2) { ItemExample.new }
    let(:item3) { ItemExample.new }
    let(:item4) { ItemExample.new }

    before do

      stub(ItemExample).find('50c12939584aa5488a000001') { item1 }
      stub(ItemExample).find('50c12939584aa5488a000002') { item2 }
      stub(ItemExample).find('50c12939584aa5488a000003') { item3 }
      stub(ItemExample).find('50c12939584aa5488a000004') { item4 }

      @user = UserExample.new
      @request = request
    end

    it "Получаем команды из фабрики" do
      @stack = Gexp::Command::Stack.new \
        @user, @request
      @stack.size.should == @request[:params][:commands].size
    end

    it "Выбрасываем исключение если комманда уже есть" do
      dup_command = @request[:params][:commands].last.dup
      @request[:params][:commands] << dup_command
      lambda {
        @stack = Gexp::Command::Stack.new \
          @user, @request
      }.should raise_error /Command with hash .+ be exist/
    end

  end

end