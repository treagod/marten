require "./person"

module Marten::DB::Query::SQL::QuerySpec
  class Student < Person
    field :grade, :string, max_size: 15

    def __query_spec_student_profile
      @_reverse_o2o_student_profile
    end
  end
end
