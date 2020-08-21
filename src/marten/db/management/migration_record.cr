module Marten
  module DB
    module Management
      # A migration record model.
      #
      # This model class is used internally by Marten in order to keep track of the migrations that were executed for a
      # given project.
      class MigrationRecord < Marten::DB::Model
        table_name :marten_migrations

        field :id, :big_auto, primary_key: true
        field :app, :string, max_size: 255
        field :name, :string, max_size: 255
        field :applied_at, :date_time, auto_now_add: true
      end
    end
  end
end
