require 'content_api_lookup'
require 'content_store_lookup'

class ContentItemLookup
  def initialize(content_store:, content_api:)
    @content_store_lookup = ContentStoreLookup.new(content_store)
    @content_api_lookup = ContentAPILookup.new(content_api)
  end

  def lookup(path)
    content_item = lookup_in_content_store_and_content_api(path) ||
      lookup_in_content_store_and_content_api(guess_alternate_path(path)) ||
      ContentItem.new(path: path)
    content_item.tap { |item| item.organisations = guess_organisations_for(item.path) if item.organisations.empty? }
  end

private
  def lookup_in_content_store_and_content_api(path)
    content_store_item = @content_store_lookup.lookup(path)
    content_api_item = @content_api_lookup.lookup(path)
    if content_store_item && content_api_item && content_store_item.organisations.empty?
      ContentItem.new(path: content_store_item.path, organisations: content_api_item.organisations)
    else
      content_store_item || content_api_item
    end
  end

  def guess_alternate_path(path)
    if path =~ %r{/y/} || path =~ %r{(/apply|/renew)$} # smart answer or local transaction
      take_segments_of(path, number: 1)
    else # most likely to be a multi-part content item, eg a page in a mainstream guide
      # remove a path segment and try looking up again in the APIs
      path_segment_number = path.count("/")
      take_segments_of(path, number: path_segment_number - 1)
    end
  end

  def take_segments_of(path, number:)
    URI(path).path.split("/").take(number + 1).join("/")
  end

  # ideally we can always find the content item in either the Content Store
  # or the Content API, but in case we can't, determine a sensible default
  def guess_organisations_for(path)
    org_slug = if path =~ %r{^/government/world/organisations}
                 case path
                 when /dfid/ then "department-for-international-development"
                 when /uk-trade-investment/ then "uk-trade-investment"
                 else "foreign-commonwealth-office"
                 end
               else
                 # if we can't determine the org of any content,
                 # the owning organisation defaults to the owners of GOV.UK
                 'government-digital-service'
               end
    [Organisation.find_by!(slug: org_slug)]
  end
end
