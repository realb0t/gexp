# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Gexp::Command::Object do

  context "Команда pick на объекте у себя в локации" do

    before do
      @user    = UserExample.new
      @request = HashWithIndifferentAccess.new({ 
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

      @object = ItemExample.new
      @context  = Object.new

      stub(ItemExample).find.with('55a55') { @object }

      lambda {
        @command = Gexp::Command::Object.new @request[:params][:commands].first
        @command.context = @context
      }.should_not raise_error

    end

    it "Команда должна загружать объекты" do
      @command.object.should == @object
    end

    it "Для конмады определенно событие" do
      @command.event.should == :pick
    end

    it "Нельзя (так просто взять и) создать команду без параметра-объекта" do
      params = @request[:params][:commands].first
      params.delete(:objects)
      lambda {
        @command = Gexp::Command::Object.new params
      }.should raise_error Regexp.new("Can't find object")
    end

    context "#perform" do

      it "должен вызывать соотвествующее соьытие у объекта" do
        mock(@object).pick.with_any_args.once { true }
        @command.perform
        @command.should be_done
      end

      context "при успешном выполнении команды" do

        it "до вызова объект в первоначальном состоянии" do
          @object.should be_created
        end

        it "ошибок быть не должно" do
          @command.perform
          @command.errors.should be_empty
        end

        it "состояние у объекта меняется" do
          @command.perform
          @object.should be_prebuilded
        end

        it "у объекта вызываются калбеки" do
          mock(@object).modify_handlers(anything)
          mock(@object).check_handlers(anything)
          mock(@object).before_event(anything)
          mock(@object).after_event(anything)

          @command.perform
        end

        it "вызываются конструкторы обработчиков"

        it "у обработчиков действия вызывается #perform"

      end

      context "при ошибке обработчика" do

        it "последующие обработчики не вызываются"

        it "состояние объекта не"

      end

      context "При неуспешном выполнении" do

        before do
          mock(@object).pick.with_any_args.once { raise 'Something wrong' }
        end

        it "Команда должна находится в статусе failed" do
          lambda { @command.perform }.should_not raise_error
          @command.should be_failed
        end

        it "исключение должно агрегироваться в #errors" do
          @command.perform
          @command.errors.should_not be_empty
          @command.errors.last.message.should == 'Something wrong'
        end

      end

    end

  end
end