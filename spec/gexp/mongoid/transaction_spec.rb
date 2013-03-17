# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper.rb')

describe Gexp::Mongoid::Transaction do

  context "Transactional Object" do

    before do

      class Foo < Gexp::Mongoid::Transaction::Base
        field :name, type: String
        field :quantity, type: Integer
      end

      class Baz < Gexp::Mongoid::Transaction::Base
        field :name, type: String
        field :quantity, type: Integer
      end

      @foo = Foo.create(name: 'foo', quantity: 0)

    end

    it "Проверка полей Foo#*" # TODO: нужены mongoid-rspec матчеры

    context "Жизненный цикл транзакции" do

      def inner_assets_for(foo, transaction)
        foo.name = 'new_foo'
        foo.name.should == 'new_foo'
        foo._updated['name'].should == 'new_foo'
        foo.attributes['name'].should == 'foo'
        foo.transaction.should == transaction
        foo._version.should be_zero

        foo.should be_dirty_uncommited
        foo.save
      end

      def outer_assets_for(foo)
        foo.reload
        foo.name.should == 'new_foo'
        foo._transaction_id.should be_nil
        foo._updated.should be_nil
        foo._version.should_not be_zero
        foo.should be_clear
      end


      it "Изменения без транзакции" do
        @foo.reload
        @foo.name = 'new_foo'
        @foo.name.should == 'new_foo'
        @foo._updated.should be_nil
        @foo.transaction.should be_nil
        @foo.save
        @foo.reload
        @foo.name.should == 'new_foo'
      end

      it "Транзакция на внутреннем новом объекте" do
        foo = nil

        Gexp::Mongoid::Transaction.with do |context|
          foo = Foo.create(name: 'foo', quantity: 0)
          inner_assets_for foo, context.transaction
        end

        outer_assets_for foo
      end

      it "Транзакция на внутреннем загруженном объекте" do

        exist = Foo.create(name: 'foo', quantity: 0)
        foo   = nil
        Gexp::Mongoid::Transaction.with do |context|
          foo = Foo.find(exist)
          inner_assets_for foo, context.transaction
        end

        outer_assets_for foo
      end

      it "Транзакция на внешнем новом объекте" do
        foo = Foo.create(name: 'foo', quantity: 0)
        Gexp::Mongoid::Transaction.with do |context|
          inner_assets_for foo, context.transaction
        end

        outer_assets_for foo
      end

      it "Транзакция на внешнем загруженном объекте" do
        exist = Foo.create(name: 'foo', quantity: 0)
        foo = Foo.create(name: 'foo', quantity: 0)

        Gexp::Mongoid::Transaction.with(foo) do |context|
          foo.transaction.should == context.transaction
          context.transaction.objects.include?(foo).should == true
          inner_assets_for foo, context.transaction
        end

        outer_assets_for foo
      end

    end

    context "Проверка признаков объекта" do

      it "Чистый объект" do
        @foo.should be_clear
        @foo.should_not be_dirty_commited
        @foo.should_not be_dirty_uncommited
      end

      it "Грязный закомиченный объект" do
        @foo.create_update
        @foo._transaction_id = '12312312asd3123'

        @foo.should_not be_clear
        @foo.should be_dirty_commited
        @foo.should_not be_dirty_uncommited
      end

      it "Грязный незакомиченынй объект" do
        @foo.create_update
        @foo.transaction = Gexp::Mongoid::Transaction::Instance.create
        @foo.should_not be_clear
        @foo.should_not be_dirty_commited
        @foo.should be_dirty_uncommited

        Gexp::Mongoid::Transaction::Observer.finish_transaction!
      end

    end

    context "Загрузка и запись" do

      before do
        @foo = Foo.create(name: 'name', quantity: 0)
        @baz = Baz.create(name: 'name', quantity: 0)
      end

      it "чистого объекта" do
        loaded = Foo.find(@foo.id)
        loaded.should be_clear
      end

      it "В нормальном режиме" do
        Gexp::Mongoid::Transaction.with do |context|
          foo = Foo.find(@foo.id)
          foo.name = 'new_name_foo'

          baz = Baz.find(@baz.id)
          baz.name = 'new_name_baz'
        end

        @foo.reload
        @foo.name.should == 'new_name_foo'
        @foo._version.should_not be_zero
        @foo.should be_clear

        @baz.reload
        @baz.name.should == 'new_name_baz'
        @baz._version.should_not be_zero
        @baz.should be_clear
      end

      it "грязного не закоммиченного объекта с проваленной транзакцией" do
        obj = @foo
        lambda {
          Gexp::Mongoid::Transaction.with do |context|
            obj.name = 'new_name'
            obj.should be_dirty_uncommited
            obj.save
            obj.reload
            obj.name.should == 'name'
            raise 'Something wrong' 
          end
        }.should raise_error /Something wrong/

        loaded = Foo.find(obj.id)
        loaded.should be_clear

        loaded.name.should == 'name'
      end

      it "грязного не закоммиченного объекта при проваленом коммите транзакции" do
        lambda {
          Gexp::Mongoid::Transaction.with do |context|
            stub(context).end_transaction { raise 'Something wrong' }
            @foo.name = 'new_name'
            @foo.save
          end
        }.should raise_error /Something wrong/

        @foo.should be_dirty
        @foo.should be_dirty_commited
        #mock(@foo).clear_commited!.once
        mock(@foo).clear_uncommited!.never
        @foo.reload
        @foo.name.should == 'new_name'
        @foo.should be_clear
      end

    end

  end

end