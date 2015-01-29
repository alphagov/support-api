require 'plek'
require 'gds_api/content_api'
require 'gds_api/content_store'
require 'gds_api/organisations'
require 'content_api/enhanced_content_api'

content_api = GdsApi::ContentApi.new(Plek.find('contentapi'))
content_store = GdsApi::ContentStore.new(Plek.find('content-store'))
SupportApi.enhanced_content_api = ContentAPI::EnhancedContentAPI.new(content_api, content_store)
