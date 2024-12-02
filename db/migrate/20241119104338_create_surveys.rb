class CreateSurveys < ActiveRecord::Migration[7.2]
  def change
    create_table :surveys do |t|
      t.string :title
      t.string :description
      t.datetime :starting_date
      t.datetime :closing_date
      t.string :status, default: 'inactive'
      t.integer :created_by, null: false
      t.timestamps
    end
  end
end
