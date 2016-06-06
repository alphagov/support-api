class AggregatedServiceFeedback < AnonymousContact

  def type
    "aggregated-service-feedback"
  end

  def as_json(options = {})
    attributes_to_serialise = [
      :type, :path, :id, :created_at, :slug,
      :service_satisfaction_rating, :details,
    ]
    super({
      only: attributes_to_serialise,
      methods: :url,
    }.merge(options))
  end

end
