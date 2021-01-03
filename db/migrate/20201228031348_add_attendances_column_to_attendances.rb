class AddAttendancesColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_end_plan, :datetime
    add_column :attendances, :next_day_check, :string, default: "0"
    add_column :attendances, :overtime_detail, :string
    add_column :attendances, :overtime_superior_id, :integer
    add_column :attendances, :overtime_status, :string
    add_column :attendances, :overtime_approval, :integer, default: 1
    add_column :attendances, :overtime_check, :string, default: "0"
    add_column :attendances, :overtime_hour, :string
    add_column :attendances, :overtime_superior_name, :string
    add_column :attendances, :change_started_at, :datetime
    add_column :attendances, :change_finished_at, :datetime
    add_column :attendances, :change_next_day_check, :string
    add_column :attendances, :change_note, :string
    add_column :attendances, :change_status, :string
    add_column :attendances, :change_approval, :integer, default: 1
    add_column :attendances, :change_superior_id, :integer
    add_column :attendances, :change_superior_name, :string
    add_column :attendances, :change_check, :string
    add_column :attendances, :one_month_apply_superior_id, :integer
    add_column :attendances, :one_month_approval, :integer, default: 1
    add_column :attendances, :one_month_status, :string
    add_column :attendances, :one_month_check, :string, default: "0"
    add_column :attendances, :one_month_superior_name, :string
    add_column :attendances, :change_date, :datetime
    add_column :attendances, :calendar_day, :date
    add_column :attendances, :search_day, :date
  end
end
