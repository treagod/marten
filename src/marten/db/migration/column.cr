require "./column/concerns/**"

require "./column/base"
require "./column/big_int"
require "./column/bool"
require "./column/date_time"
require "./column/int"
require "./column/string"
require "./column/text"
require "./column/uuid"

require "./column/auto"
require "./column/big_auto"

require "./column/foreign_key"

module Marten
  module DB
    abstract class Migration
      module Column
        annotation Registration
        end

        @@registry = {} of ::String => Base.class

        def self.registry
          @@registry
        end

        macro register(id, column_klass)
          {% klass = column_klass.resolve %}

          @[Marten::DB::Migration::Column::Registration(id: {{ id }})]
          class ::{{ klass.id }}; end
          add_column_to_registry({{ id }}, {{ klass }})
        end

        register "auto", Auto
        register "big_auto", BigAuto
        register "big_int", BigInt
        register "bool", Bool
        register "date_time", DateTime
        register "foreign_key", ForeignKey
        register "int", Int
        register "string", String
        register "text", Text
        register "uuid", UUID

        protected def self.add_column_to_registry(id : ::String | Symbol, column_klass : Base.class)
          @@registry[id.to_s] = column_klass
        end
      end
    end
  end
end
