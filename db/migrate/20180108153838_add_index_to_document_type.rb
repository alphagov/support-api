class AddIndexToDocumentType < ActiveRecord::Migration[5.0]
  def change
    add_index :content_items, :document_type
  end
end
