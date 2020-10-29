module Marten
  module DB
    module Field
      # Abstract base field implementation.
      abstract class Base
        @primary_key : ::Bool
        @blank : ::Bool
        @null : ::Bool
        @name : ::String?
        @db_column : ::String | Symbol | Nil
        @db_index : ::Bool

        # Returns the ID of the field used in the associated model.
        getter id

        # Returns the human-readable name of the field.
        getter name

        def initialize(
          @id : ::String,
          @primary_key = false,
          @blank = false,
          @null = false,
          @unique = false,
          @editable = true,
          @name = nil,
          @db_column = nil,
          @db_index = false
        )
        end

        # Extracts the field value from a DB result set and returns the right object corresponding to this value.
        abstract def from_db_result_set(result_set : ::DB::ResultSet)

        # Returns a migration column object corresponding to the field at hand.
        abstract def to_column : Management::Column::Base

        # Converts the field value to the corresponding DB value.
        abstract def to_db(value) : ::DB::Any

        # Returns the name of the column associated with the considered field.
        def db_column
          @db_column.try(&.to_s) || @id
        end

        # Returns true if an index should be created at the database level for the field.
        def db_index?
          @db_index
        end

        # Returns a boolean indicating whether the field is a primary key.
        def primary_key?
          @primary_key
        end

        # Returns a boolean indicating whether the field can be blank validation-wise.
        def blank?
          @blank
        end

        # Returns a boolean indicating whether the field can be null at the database level.
        def null?
          @null
        end

        # Returns a boolean indicating whether the field value should be unique throughout the associated table.
        def unique?
          @unique
        end

        # Runs pre-save logic for the specific field and record at hand.
        #
        # This method does nothing by default but can be overridden for specific fields that need to set values on the
        # model instance before save or perform any pre-save logic.
        def prepare_save(record, new_record = false)
        end

        # Runs custom validation logic for a specific model field and model object.
        #
        # This method should be overriden for each field implementation that requires custom validation logic.
        def validate(record, value)
        end

        # :nodoc:
        macro check_definition(field_id, kwargs)
        end

        # :nodoc:
        macro contribute_to_model(model_klass, field_id, field_ann, kwargs)
          # Registers the field to the model class.

          class ::{{ model_klass }}
            register_field(
              {{ @type }}.new(
                {{ field_id.stringify }},
                {% unless kwargs.is_a?(NilLiteral) %}**{{ kwargs }}{% end %}
              )
            )

            @[Marten::DB::Model::Table::FieldInstanceVariable(
              field_klass: {{ @type }},
              field_kwargs: {% unless kwargs.is_a?(NilLiteral) %}{{ kwargs }}{% else %}nil{% end %},
              field_type: {{ field_ann[:exposed_type] }}
            )]

            @{{ field_id }} : {{ field_ann[:exposed_type] }}?

            def {{ field_id }} : {{ field_ann[:exposed_type] }}?
              @{{ field_id }}
            end

            def {{ field_id }}!
              @{{ field_id }}.not_nil!
            end

            def {{ field_id }}=(@{{ field_id }} : {{ field_ann[:exposed_type] }}?); end
          end
        end

        protected def perform_validation(record : Model)
          value = record.get_field_value(id)

          if value.nil? && !@null && @editable
            record.errors.add(id, null_error_message(record), type: :null)
          elsif empty_value?(value) && !@blank && @editable
            record.errors.add(id, blank_error_message(record), type: :blank)
          end

          validate(record, value)
        end

        protected def related_model
          raise NotImplementedError.new("#relation_model must be implemented by subclasses if necessary")
        end

        protected def relation?
          false
        end

        protected def relation_name
          raise NotImplementedError.new("#relation_name must be implemented by subclasses if necessary")
        end

        private def empty_value?(value) : ::Bool
          value.nil?
        end

        private def null_error_message(_record)
          # TODO: add I18n support.
          "This field cannot be null."
        end

        private def blank_error_message(_record)
          # TODO: add I18n support.
          "This field cannot be blank."
        end

        private def raise_unexpected_field_value(value)
          raise Errors::UnexpectedFieldValue.new("Unexpected value received for field '#{id}': #{value}")
        end
      end
    end
  end
end
