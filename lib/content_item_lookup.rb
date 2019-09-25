require "content_store_lookup"
require "looked_up_content_item"

class ContentItemLookup
  def initialize(content_store:)
    @content_store_lookup = ContentStoreLookup.new(content_store)
  end

  def lookup(path)
    @content_store_lookup.lookup(path) ||
      @content_store_lookup.lookup(guess_alternate_path(path)) ||
      LookedUpContentItem.new(path: path)
  end

private

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
end
