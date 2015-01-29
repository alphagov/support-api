require 'content_api/base_info_lookup'

module ContentAPI
  class OrgsContentLookup
    def initialize(content_store)
      @content_store = content_store
    end

    def applies?(path)
      path =~ %r{^/government/organisations/.+}
    end

    def organisations_for(path)
      path_to_lookup = content_item_path(path)
      response = @content_store.content_item(path_to_lookup)

      if response
        [{
          slug: organisation_slug(path),
          web_url: Plek.new.website_root + response["base_path"],
          title: response["title"],
        }]
      else
        []
      end
    end

    def content_item_path(path)
      URI(path).path.split("/")[0..3].join("/")
    end

    private
    def organisation_slug(path)
      URI(path).path.split("/")[3]
    end
  end
end
