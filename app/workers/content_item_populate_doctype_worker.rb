class ContentItemPopulateDoctypeWorker
  include Sidekiq::Worker

  def perform
    content_store = GdsApi::ContentStore.new(Plek.find('content-store'))
    document_type_not_found = []

    ContentItem.all.each do |content_item|
      found_content_item = content_store.content_item(content_item.path)

      if found_content_item.present?
        document_type = looked_up_item["document_type"]
        content_item.update_attributes(:document_type, document_type)
      else
        document_type_not_found << content_item.path
      end
    end

    Rails.logger.warn "Document type not found for the following content items: #{document_type_not_found.join(', ')}"
  end
end
