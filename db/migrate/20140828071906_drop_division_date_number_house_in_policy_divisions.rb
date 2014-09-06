class DropDivisionDateNumberHouseInPolicyDivisions < ActiveRecord::Migration
  def change
    remove_index :policy_divisions, name: "policies_date_number_house_dream_id"
    add_index :policy_divisions, [:division_id, :policy_id], unique: true
    add_index :policy_divisions, :division_id
    remove_column :policy_divisions, :division_date, :date, null: false
    remove_column :policy_divisions, :division_number, :integer, null: false
    remove_column :policy_divisions, :house, :string, limit: 8, null: false
  end
end
