module Marten
  module DB
    module Management
      class Statement
        class Columns < Reference
          def initialize(@quote_proc : Proc(String, String), @table : String, @columns : Array(String))
          end

          def references_column?(table : String, column : String?)
            @table == table && @columns.any? { |c| c == column }
          end

          def references_table?(name : String?)
            @table == name
          end

          def rename_table(old_name : String, new_name : String)
            @table = new_name if @table == old_name
          end

          def to_s
            @columns.map { |c| @quote_proc.call(c) }.join(", ")
          end
        end
      end
    end
  end
end