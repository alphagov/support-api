class PopulateDocumentTypeForContentItems < ActiveRecord::Migration[5.0]
  def up
    ContentItemPopulateDoctypeWorker.perform_async
  end

  def down
    ContentItem.update_all(document_type: nil)
  end
end
