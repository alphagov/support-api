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
        create(:anonymous_contact, created_at: 60.days.ago),
        create(:anonymous_contact, created_at: 70.days.ago),
        create(:anonymous_contact, created_at: 80.days.ago),
        create(:anonymous_contact, created_at: 90.days.ago),
      ]
    )

    expect(ContentItem.summary).to eq([
      { path: "/abc", last_7_days: 1, last_30_days: 2, last_90_days: 3 },
      { path: "/def", last_7_days: 0, last_30_days: 0, last_90_days: 4 }
    ])

    expect(ContentItem.summary("last_90_days")).to eq([
      { path: "/def", last_7_days: 0, last_30_days: 0, last_90_days: 4 },
      { path: "/abc", last_7_days: 1, last_30_days: 2, last_90_days: 3 }
    ])

    expect(ContentItem.summary("path")).to eq([
      { path: "/abc", last_7_days: 1, last_30_days: 2, last_90_days: 3 },
      { path: "/def", last_7_days: 0, last_30_days: 0, last_90_days: 4 }
    ])
  end

  it "aggregates content items with similar paths" do
    create(:content_item, organisations: orgs, path: "/abc",
      anonymous_contacts: [
        create(:anonymous_contact, created_at: 15.days.ago),
        create(:anonymous_contact, created_at: 15.days.ago),
      ]
    )
    create(:content_item, organisations: orgs, path: "/abc",
      anonymous_contacts: [
        create(:anonymous_contact, created_at: 15.days.ago),
        create(:anonymous_contact, created_at: 15.days.ago),
      ]
    )

    expect(ContentItem.summary).to eq([
      { path: "/abc", last_7_days: 0, last_30_days: 4, last_90_days: 4 },
    ])
  end
end
