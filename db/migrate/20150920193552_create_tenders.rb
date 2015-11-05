class CreateTenders < ActiveRecord::Migration
  def change
    create_table :tenders do |t|
      t.decimal  :initial_value_amount
      t.string   :initial_value_currency
      t.intenger :initial_value_x_vat
      t.decimal  :min_value_amount
      t.decimal  :min_value_x_amount_eur
      t.decimal  :value_amount
      t.decimal  :value_x_amount_eur
      t.bool     :value_x_vatbool
      t.string   :value_currency
      t.integer  :value_x_vat
      t.decimal  :x_initial_value_x_amount_eur
      t.bool     :x_initial_value_x_vatbool
    end
  end
end
