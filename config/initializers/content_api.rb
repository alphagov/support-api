require 'plek'
require 'gds_api/content_api'
require 'content_api/enhanced_content_api'

content_api = GdsApi::ContentApi.new(Plek.find('contentapi'))
SupportApi.enhanced_content_api = ContentAPI::EnhancedContentAPI.new(content_api)
