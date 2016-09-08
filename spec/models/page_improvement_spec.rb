require 'rails_helper'

describe PageImprovement, 'validations' do
  it 'validates presence of path' do
    page_improvement = described_class.new({})
    page_improvement.valid?

    expect(page_improvement.errors.messages).to include(path: include("can't be blank"))
  end

  it 'validates presence of description' do
    page_improvement = described_class.new({})
    page_improvement.valid?

    expect(page_improvement.errors.messages).to include(description: include("can't be blank"))
  end
end

describe PageImprovement, '#zendesk_ticket_attributes' do
  it "generates a hash of attributes to create a Zendesk ticket" do
    page_improvement = described_class.new({
      path: '/service-manual/test',
      description: 'I love this page.',
      name: 'John',
      email: 'john@example.com'
    })

    expect(page_improvement.zendesk_ticket_attributes).to eq({
      'subject' => '/service-manual/test',
      'comment' => {
        'body' => "[Details]\nI love this page.\n\n[Name]\nJohn\n\n[Email]\njohn@example.com\n\n[Path]\n/service-manual/test"
      }
    })
  end

  it "generates a hash of attributes where the body omits the optional name and email" do
    page_improvement = described_class.new({
      path: '/service-manual/test',
      description: 'I love this page.',
    })

    expect(page_improvement.zendesk_ticket_attributes).to eq({
      'subject' => '/service-manual/test',
      'comment' => {
        'body' => "[Details]\nI love this page.\n\n[Name]\n\n\n[Email]\n\n\n[Path]\n/service-manual/test"
      }
    })
  end
end
