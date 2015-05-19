require 'rails_helper'

describe ContentItem do
  let(:orgs) { create_list(:organisation, 2) }

  context "#for_organisation" do
    it "should be filter only content items for that org" do
      item1 = create(:content_item, organisations: [orgs[0]])
      item2 = create(:content_item, organisations: [orgs[1]])
      item3 = create(:content_item, organisations: [orgs[1]])

      expect(ContentItem.for_organisation(orgs[1])).to contain_exactly(item2, item3)
    end
  end

  it "calculates anonymous feedback counts for recent time intervals" do
    item = create(:content_item, organisations: orgs, path: "/abc",
      anonymous_contacts: [
        create(:anonymous_contact, created_at: 5.days.ago),
        create(:anonymous_contact, created_at: 15.days.ago),
        create(:anonymous_contact, created_at: 70.days.ago),
        create(:anonymous_contact, created_at: 100.days.ago),
      ]
    )

    another_item = create(:content_item, organisations: orgs, path: "/def",
      anonymous_contacts: [
        create(:anonymous_contact, created_at: 70.days.ago),
      ]
    )

    expect(ContentItem.summary).to contain_exactly(
      { path: "/abc", last_7_days: 1, last_30_days: 2, last_90_days: 3 },
      { path: "/def", last_7_days: 0, last_30_days: 0, last_90_days: 1 }
    )
  end
end
