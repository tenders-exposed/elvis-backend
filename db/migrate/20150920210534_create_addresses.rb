class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.references :supplier
      t.string :country_name, null: false
      t.string :locality
      t.string :street_address
      t.string :postal_code
      t.string :email
      t.string :telephone
      t.string :x_url
    end
  end
end
