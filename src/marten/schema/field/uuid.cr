module Marten
  abstract class Schema
    module Field
      # Represents a UUID schema field.
      class UUID < Base
        def deserialize(value) : ::UUID?
          case value
          when Nil
            value
          when ::String
            value.empty? ? nil : ::UUID.new(value)
          else
            raise_unexpected_field_value(value)
          end
        rescue ArgumentError
          raise_unexpected_field_value(value)
        end

        def serialize(value) : ::String?
          value.try(&.to_s)
        end

        private def invalid_error_message(_schema)
          I18n.t("marten.schema.field.uuid.errors.invalid")
        end
      end
    end
  end
end