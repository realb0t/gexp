require 'singleton'
require 'mongoid'

# Gexp::Mongoid::Transaction::Observer.started?

module Gexp
  module Mongoid
    module Transaction

      SYSTEM_FIELDS = [
        :_updated,
        :_version,
        :_transaction_id,
      ]

      class Observer #TODO: Переделать на контекст
        class << self

          def runned
            @runned
          end

          def started?
            @runned ||= false
          end

          def start_transaction!(transaction)
            @runned = transaction
          end

          def finish_transaction!
            @runned = false
          end

        end
      end

      class Instance

        attr_accessor :operation, :error
        include ::Mongoid::Document

        has_many :objects, class_name: 'Gexp::Mongoid::Transaction::Base'

        def initialize(*args)
          super(*args)
          Observer.start_transaction!(self)
        end

        def delete
          Observer.finish_transaction!
          super
        end

        def commit
        end

      end

      class << self

        def with(*objects, &block)

          begin
            self.start_transaction(objects)
            block.call self
            Observer.finish_transaction!
            self.transaction.objects.map(&:save)
            self.end_transaction
          rescue => e
            raise
          ensure
            if @transaction
              @transaction.delete unless @transaction.deleted?
            end
          end

        end

        def transaction
          @transaction
        end

        protected

          def start_transaction(objects)
            @transaction = Instance.create
            objects.each { |obj| 
              obj.transaction ||= @transaction 
            }
          end

          def end_transaction
            @transaction.delete
            @transaction.objects.map(&:transaction_commit)
          end

      end

      #extend ActiveSupport::Concern

      class Base

        class << self
          def inherited(sub)
            sub.instance_eval do

              def field(name, *args)
                super # вызов Mongoid::Document#field

                return if SYSTEM_FIELDS.include? name.to_sym

                field_setter = "#{name}=".to_sym
                field_getter = "#{name}"

                # переопределяем сеттер
                define_method(field_setter) do |val|

                  if Observer.started?
                    self.transaction ||= Observer.runned
                  end

                  if self.new_record?
                    super(val)
                  else
                    if Observer.started?
                      # Создание грязной версии если еще нет
                      self.create_update
                      self._updated[name.to_s] = val
                    else
                      super(val)
                    end
                  end
                end

                define_method(field_getter) do
                  # Если транзакция началась и текущий объект не _updated
                  if Observer.started? && self._updated
                    self._updated[name.to_s]
                  else
                    super()
                  end
                end

              end
            end
          end
        end

        include ::Mongoid::Document

        field :_version, type: Integer, default: 0
        field :_updated, type: Hash

        belongs_to :transaction, class_name: 'Gexp::Mongoid::Transaction::Instance', foreign_key: :_transaction_id

        after_initialize :check_dirty, :if => lambda { |o| not o.new_record? }

        def can_save?
          self.new_record? || (not Observer.started?)
        end

        def save
          return super if can_save?
          true
        end

        #def save!
        #  return super if can_save?
        #  true
        #end

        def create_update
          self._updated ||= self.attributes.except('_id', '_type')
        end

        # Вызывается только тогда, когда все объекты сохраненны
        def transaction_commit
          if self._updated
            self.updated_apply!
            self.clear_updated!
            self._version += 1
            self._transaction_id = nil
            self.save
          end
        end

        def clear_updated!
          self._updated = nil
        end

        def updated_apply!
          self.attributes = self.attributes.merge(self._updated)
        end

        # Проверка объекта на незаконченную транзакцию
        # если объект "грязный", то чистим его
        def check_dirty
          self.clear! if self.dirty?
        end

        def clear_commited!
          self.updated_apply!
          self.clear_updated!
          self._version += 1
          self._transaction_id = nil
        end

        def clear_uncommited!
          _transaction_id = Observer.started? ? Observer.runned.id : nil
          self._transaction_id = _transaction_id
          self.clear_updated!
        end

        def clear!
          if self.dirty_commited?
            self.clear_commited! 
          elsif self.dirty_uncommited?
            self.clear_uncommited!
          end

          self.save
        end

        def dirty?
          self.dirty_commited? ||
            self.dirty_uncommited?
        end

        # Чистый
        def clear?
          self._updated.nil? && self._transaction_id.nil?
        end

        # Существование у объекта транзакции
        def exist_transaction?
          return false unless self._transaction_id
          Instance.find(self._transaction_id)
          true
        rescue ::Mongoid::Errors::DocumentNotFound
          false
        end

        # Грязный закоммиченный
        def dirty_commited?
          self.update_exist? && 
            self._transaction_id.present? &&
            (not self.exist_transaction?)
        end

        # Грязный незакоммиченный
        def dirty_uncommited?
          self.update_exist? && 
            self._transaction_id.present? &&
            self.exist_transaction?
        end

        # Сущетвование не закоммиченной версии
        def update_exist?
          self._updated.present?
        end

      end

    end
  end
end