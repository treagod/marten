require "./spec_helper"

describe Marten::DB::Field::DateTime do
  describe "::new" do
    it "initializes a date time field instance with the expected defaults" do
      field = Marten::DB::Field::DateTime.new("my_field")
      field.id.should eq "my_field"
      field.primary_key?.should be_false
      field.blank?.should be_false
      field.null?.should be_false
      field.unique?.should be_false
      field.editable?.should be_true
      field.db_column.should eq field.id
      field.db_index?.should be_false
      field.auto_now?.should be_false
      field.auto_now_add?.should be_false
    end

    it "sets the field as blankable and not editable if auto_now is set to true" do
      field = Marten::DB::Field::DateTime.new("my_field", auto_now: true)
      field.auto_now?.should be_true
      field.blank?.should be_true
      field.editable?.should be_false
    end

    it "sets the field as blankable and not editable if auto_now_add is set to true" do
      field = Marten::DB::Field::DateTime.new("my_field", auto_now_add: true)
      field.auto_now_add?.should be_true
      field.blank?.should be_true
      field.editable?.should be_false
    end
  end

  describe "#auto_now?" do
    it "returns true if auto_now is set to true" do
      field = Marten::DB::Field::DateTime.new("my_field", auto_now: true)
      field.auto_now?.should be_true
    end

    it "returns false if auto_now is set to false" do
      field = Marten::DB::Field::DateTime.new("my_field", auto_now: false)
      field.auto_now?.should be_false
    end
  end

  describe "#auto_now_add?" do
    it "returns true if auto_now_add is set to true" do
      field = Marten::DB::Field::DateTime.new("my_field", auto_now_add: true)
      field.auto_now_add?.should be_true
    end

    it "returns false if auto_now_add is set to false" do
      field = Marten::DB::Field::DateTime.new("my_field", auto_now_add: false)
      field.auto_now_add?.should be_false
    end
  end

  describe "#from_db_result_set" do
    it "is able to read a date time froma a DB result set" do
      field = Marten::DB::Field::DateTime.new("my_field")

      Marten::DB::Connection.default.open do |db|
        db.query(
          {% if env("MARTEN_SPEC_DB_CONNECTION").id == "postgresql" || env("MARTEN_SPEC_DB_CONNECTION").id == "mysql" %}
            "SELECT now()"
          {% else %}
            "SELECT '2017-09-28 02:57:14.839000'"
          {% end %}
        ) do |rs|
          rs.each do
            value = field.from_db_result_set(rs)
            value.should be_a Time
            value.not_nil!.zone.name.should eq Marten.settings.time_zone.to_s
          end
        end
      end
    end

    it "is able to read a null value from a DB result set" do
      field = Marten::DB::Field::DateTime.new("my_field")

      Marten::DB::Connection.default.open do |db|
        db.query("SELECT NULL") do |rs|
          rs.each do
            field.from_db_result_set(rs).should be_nil
          end
        end
      end
    end
  end

  describe "#prepare_save" do
    it "sets the current datetime if auto_now_add is set to true and the record is new" do
      user = TestUser.new
      field = Marten::DB::Field::DateTime.new("created_at", auto_now_add: true)

      user.created_at.should be_nil

      time = Time.local
      Timecop.freeze(time) do
        field.prepare_save(user, true)
      end

      user.created_at.should eq time
    end

    it "does not persist the current datetime if auto_now_add is set to true and the record is not new" do
      user = TestUser.new
      field = Marten::DB::Field::DateTime.new("created_at", auto_now_add: true)

      user.created_at.should be_nil

      field.prepare_save(user, false)

      user.created_at.should be_nil
    end

    it "sets the current datetime if auto_now is set to true and the record is new" do
      user = TestUser.new
      field = Marten::DB::Field::DateTime.new("updated_at", auto_now: true)

      user.updated_at.should be_nil

      time = Time.local
      Timecop.freeze(time) do
        field.prepare_save(user, true)
      end

      user.updated_at.should eq time
    end

    it "sets the current datetime if auto_now is set to true and the record is new" do
      user = TestUser.new
      field = Marten::DB::Field::DateTime.new("updated_at", auto_now: true)

      user.updated_at.should be_nil

      time = Time.local
      Timecop.freeze(time) do
        field.prepare_save(user, false)
      end

      user.updated_at.should eq time
    end

    it "does not persist the current datetime if no auto option is used and the record is new" do
      user = TestUser.new
      field = Marten::DB::Field::DateTime.new("created_at")

      user.created_at.should be_nil

      field.prepare_save(user, true)

      user.created_at.should be_nil
    end

    it "does not persist the current datetime if no auto option is used and the record is not new" do
      user = TestUser.new
      field = Marten::DB::Field::DateTime.new("created_at")

      user.created_at.should be_nil

      field.prepare_save(user, false)

      user.created_at.should be_nil
    end
  end

  describe "#to_column" do
    it "returns the expected column" do
      field = Marten::DB::Field::DateTime.new("my_field", db_column: "my_field_col")
      column = field.to_column
      column.should be_a Marten::DB::Management::Column::DateTime
      column.name.should eq "my_field_col"
      column.primary_key?.should be_false
      column.null?.should be_false
      column.unique?.should be_false
      column.index?.should be_false
      column.default.should be_nil
    end

    it "properly forwards the default value if applicable" do
      default_dt = Time.local
      field = Marten::DB::Field::DateTime.new("my_field", db_column: "my_field_col", default: default_dt)
      column = field.to_column
      column.default.should eq default_dt
    end
  end

  describe "#default" do
    it "returns nil by default" do
      field = Marten::DB::Field::DateTime.new("my_field")
      field.default.should be_nil
    end

    it "returns the configured default" do
      default_dt = Time.local
      field = Marten::DB::Field::DateTime.new("my_field", default: default_dt)
      field.default.should eq default_dt
    end
  end

  describe "#to_db" do
    it "returns nil if the value is nil" do
      field = Marten::DB::Field::DateTime.new("my_field")
      field.to_db(nil).should be_nil
    end

    it "returns a Time value if the initial value is a Time" do
      field = Marten::DB::Field::DateTime.new("my_field")

      time = Time.local
      Timecop.freeze(time) do |frozen_time|
        field.to_db(frozen_time).should eq frozen_time
      end
    end

    it "raises UnexpectedFieldValue if the value is not supported" do
      field = Marten::DB::Field::DateTime.new("my_field")

      expect_raises(Marten::DB::Errors::UnexpectedFieldValue) do
        field.to_db(["foo", "bar"])
      end
    end
  end
end
