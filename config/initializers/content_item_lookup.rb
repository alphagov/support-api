require 'plek'
require 'gds_api/content_api'
require 'gds_api/content_store'
require 'gds_api/organisations'
require 'content_item_lookup'

content_api = GdsApi::ContentApi.new(Plek.find('contentapi'))
content_store = GdsApi::ContentStore.new(Plek.find('content-store'))
SupportApi.content_item_lookup = ContentItemLookup.new(content_api: content_api, content_store: content_store)
