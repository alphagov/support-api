require 'rails_helper'
require 'content_api_lookup'
require 'plek'
require 'gds_api/test_helpers/content_api'

describe ContentAPILookup, '#lookup' do
  include GdsApi::TestHelpers::ContentApi

  let(:content_api) { GdsApi::ContentApi.new(Plek.find('contentapi')) }
  let(:subject) { ContentAPILookup.new(content_api) }

  context 'when the response indicates the item is not present' do
    before do
      content_api_does_not_have_an_artefact('contact-ukvi/overview')
    end

    it 'returns nil' do
      expect(subject.lookup('/contact-ukvi/overview')).to eq nil
    end
  end

  context 'when the response indicates the item has been archived' do
    before do
       content_api_has_an_archived_artefact('contact-ukvi/overview')
    end

    it 'returns nil' do
      expect(subject.lookup('/contact-ukvi/overview')).to eq nil
    end
  end
end
