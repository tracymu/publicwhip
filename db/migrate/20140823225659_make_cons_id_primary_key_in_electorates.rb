class MakeConsIdPrimaryKeyInElectorates < ActiveRecord::Migration
  def change
    Electorate.all.each { |e| e.update! id: e.cons_id }
    remove_column :electorates, :cons_id
  end
end
