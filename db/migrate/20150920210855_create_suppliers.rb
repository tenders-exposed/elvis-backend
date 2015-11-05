class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.string :name, null: false
      t.string :x_slug
    end
  end
end
