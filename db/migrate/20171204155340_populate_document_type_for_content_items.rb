class PopulateDocumentTypeForContentItems < ActiveRecord::Migration[5.0]
  def up
    ContentItemPopulateDoctypeJob.perform_async
  end

  def down
    ContentItem.update_all(document_type: nil)
  end
end
