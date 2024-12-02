class AddColumnInSUrvey < ActiveRecord::Migration[7.2]
  def change
    add_column :surveys, :is_submitted, :boolean, default: false unless column_exists? :surveys, :is_submitted
  end
end
