require "rails_helper"

describe ContentItem do
  context "#for_organisation" do
    it "should be filter only content items for that org" do
      orgs = create_list(:organisation, 2)
      create(:content_item, organisations: [orgs[0]])
      item2 = create(:content_item, organisations: [orgs[1]])
      item3 = create(:content_item, organisations: [orgs[1]])

      expect(ContentItem.for_organisation(orgs[1])).to contain_exactly(item2, item3)
    end
  end
end
