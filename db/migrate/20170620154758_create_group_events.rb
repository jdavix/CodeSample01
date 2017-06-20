class CreateGroupEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :group_events do |t|
      t.string :name
      t.text :description
      t.string :location
      t.string :state, default: 'draft'
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
