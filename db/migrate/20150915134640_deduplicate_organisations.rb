class DeduplicateOrganisations < ActiveRecord::Migration
  class Organisation < ApplicationRecord
    has_and_belongs_to_many :content_items
  end

  def up
    remove_duplicate_organisations
    deduplicate_content_items_organisations_join_table
  end

  def down
    remove_index :content_items_organisations, name: :index_content_items_organisations_unique
    remove_index :organisations, :content_id
    add_index :organisations, :content_id, name: :index_organisations_on_content_id, using: :btree
  end

private
  def remove_duplicate_organisations
    Organisation.all.group_by(&:content_id).each do |content_id, organisations|
      if organisations.count > 1
        first_organisation = organisations.min_by(&:id)
        dupe_organisations = organisations - [first_organisation]

        # Point any content_items for the duplicate organisations at the
        # first_organisation. Note that this could create duplicate rows, which
        # we deduplicate later.
        execute """
            UPDATE content_items_organisations
            SET organisation_id=#{first_organisation.id}
            WHERE organisation_id IN (#{dupe_organisations.map(&:id).join(",")})
        """

        dupe_organisations.each(&:delete)
      end
    end

    # Change the index on organisations content_id to be unique
    remove_index :organisations, name: :index_organisations_on_content_id
    add_index :organisations, :content_id, unique: true
  end

  def deduplicate_content_items_organisations_join_table
    # Create a new table to contain the deduplicated relationship
    execute """
        CREATE TABLE content_items_organisations_deduped (LIKE content_items_organisations)
    """

    # Copy the unique rows into the new table
    execute """
        INSERT INTO content_items_organisations_deduped
        SELECT DISTINCT content_item_id, organisation_id
        FROM content_items_organisations
    """

    # Rename the new table over the old. Have to drop it first to achieve this.
    drop_table :content_items_organisations
    rename_table :content_items_organisations_deduped, :content_items_organisations

    # Add a unique index so that duplicate join rows aren't created in future
    add_index :content_items_organisations, [:content_item_id, :organisation_id], name: :index_content_items_organisations_unique, unique: true
  end

  def execute(sql)
    ApplicationRecord.connection.execute(sql)
  end
end
