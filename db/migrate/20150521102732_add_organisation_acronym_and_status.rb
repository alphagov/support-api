class AddOrganisationAcronymAndStatus < ActiveRecord::Migration[5.0]
  def change
    add_column :organisations, :acronym, :string, limit: 255
    add_column :organisations, :govuk_status, :string, limit: 255
  end
end
