class ServiceFeedback < AnonymousContact
  validates_presence_of :slug, :service_satisfaction_rating
  validates :details, length: { maximum: 2**16 }
  validates_inclusion_of :service_satisfaction_rating, in: (1..5).to_a

  def type
    "service-feedback"
  end

  def as_json(options = {})
    attributes_to_serialise = %i[
      type path id created_at referrer user_agent slug
      service_satisfaction_rating details
    ]
    super({
      only: attributes_to_serialise,
      methods: :url,
    }.merge(options))
  end

  def self.transaction_slugs
    distinct.pluck(:slug).sort
  end

  def self.with_comments
    where("details IS NOT NULL")
  end
end
