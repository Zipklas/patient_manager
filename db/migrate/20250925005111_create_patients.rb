class CreatePatients < ActiveRecord::Migration[8.0]
  def change
    create_table :patients do |t|
      t.string :first_name
      t.string :last_name
      t.string :middle_name
      t.date :birthday
      t.string :gender
      t.float :height
      t.float :weight

      t.timestamps
    end
  end
end
