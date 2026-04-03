class RenameTypeToName < ActiveRecord::Migration[7.1]
  def change
    rename_column :incident_types, :type, :name
    rename_column :waste_types, :type, :name
  end
end
