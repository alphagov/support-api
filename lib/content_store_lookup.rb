class ContentStoreLookup
  def initialize(content_store)
    @content_store = content_store
  end

  def lookup(path)
    return nil if path.empty?
    response = @content_store.content_item(path)
    ContentItem.new(path: response["base_path"], organisations: organisations_from(response)) if response
  end

private
  def organisations_from(response)
    if organisation?(response)
      org_info = {
        content_id: response["content_id"],
        slug: response["base_path"].split("/").last,
        web_url: Plek.new.website_root + response["base_path"],
        title: response["title"],
      }
      [ find_or_create_org(org_info) ]
    elsif response["links"]
      org_infos = [
        response["links"]["organisations"],
        response["links"]["lead_organisations"],
        response["links"]["supporting_organisations"],
      ].compact.flatten.uniq
      org_infos.collect do |org_info|
        find_or_create_org(
          content_id: org_info["content_id"],
          slug: org_info["base_path"].split("/").last,
          web_url: Plek.new.website_root + org_info["base_path"],
          title: org_info["title"],
        )
      end
    else
      []
    end
  end

  def organisation?(response)
    response["format"].gsub("placeholder_", "") == "organisation"
  end

  def find_or_create_org(org_info)
    Organisation.create_with(org_info).find_or_create_by(content_id: org_info[:content_id])
  end
end
