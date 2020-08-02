module Marten
  module DB
    module SQL
      module Predicate
        class EndsWith < Base
          predicate_name "endswith"

          private def sql_right_operand_param(connection)
            "%#{connection.sanitize_like_pattern(super.to_s)}"
          end
        end
      end
    end
  end
end
