class ContentItemPopulateDoctypeWorker
  include Sidekiq::Worker

  def perform
    content_store = GdsApi::ContentStore.new(Plek.find("content-store"))
    document_type_errors = []

    ContentItem.all.each do |content_item|
      found_content_item = content_store.content_item(content_item.path)

      document_type = found_content_item["document_type"]
      content_item.update!(document_type: document_type)
    rescue StandardError => e
      document_type_errors << "#{content_item.path} - Error: #{e.class} #{e.message}"
    end

    Rails.logger.warn "There were errors with the following paths: #{document_type_errors.join(', ')}"
  end
end
