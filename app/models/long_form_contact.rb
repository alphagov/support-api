class LongFormContact < AnonymousContact
  validates_presence_of :details
  validates :user_specified_url, length: { maximum: 2048 }
  validates :details, length: { maximum: 2**16 }

  def type
    "long-form-contact"
  end

  def as_json(options = {})
    attributes_to_serialise = %i[
      type
      path
      id
      created_at
      referrer
      user_agent
      user_specified_url
      details
    ]
    super({
      only: attributes_to_serialise,
      methods: :url,
    }.merge(options))
  end
end
