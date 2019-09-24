class ContentStoreLookup
  def initialize(content_store)
    @content_store = content_store
  end

  def lookup(path)
    return nil if path.empty?

    begin
      response = @content_store.content_item(path)
    rescue GdsApi::HTTPNotFound, GdsApi::HTTPGone
      response = nil
    end

    if response.present?
      LookedUpContentItem.new(
        path: response["base_path"],
        organisations: organisations_from(response),
        document_type: response["document_type"] || "",
      )
    end
  end

private

  def organisations_from(response)
    if organisation?(response)
      [{
        content_id: response["content_id"],
        slug: response["base_path"].split("/").last,
        web_url: Plek.new.website_root + response["base_path"],
        title: response["title"],
      }]
    elsif response["links"]
      linked_organisations(response["links"]).map do |org_info|
        {
          content_id: org_info["content_id"],
          slug: org_info["base_path"].split("/").last,
          web_url: Plek.new.website_root + org_info["base_path"],
          title: org_info["title"],
        }
      end
    else
      []
    end
  end

  def linked_organisations(response_links)
    [
      response_links["organisations"],
      response_links["lead_organisations"],
      response_links["supporting_organisations"],
    ].compact.flatten.uniq
  end

  def organisation?(response)
    response["document_type"] == "organisation"
  end
end
