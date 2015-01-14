require 'content_api/base_info_lookup'

module ContentAPI
  class OrgsContentLookup < BaseInfoLookup
    def applies?(path)
      path =~ %r{^/government/organisations}
    end

    def organisations_for(path)
      api_path = content_item_api_path(path)
      response = api_response(api_path)

      if response && response["details"]
        [{
          slug: response["details"]["slug"],
          web_url: response["web_url"],
          title: response["title"],
        }]
      else
        []
      end
    end

    def content_item_path(path)
      "/" + URI(path).path.split("/")[1..3].join("/")
    end

    def content_item_api_path(path)
      "/" + URI(path).path.split("/")[2..3].join("/")
    end
  end
end
