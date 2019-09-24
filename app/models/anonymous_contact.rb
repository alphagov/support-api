require "field_which_may_contain_personal_information"
require "duplicate_detector"

class AnonymousContact < ApplicationRecord
  before_save :detect_personal_information

  belongs_to :content_item, optional: true
  has_many :organisations, through: :content_item

  validates :referrer, referrer_url: true, length: { maximum: 2048 }, allow_nil: true
  validates :path,     url: true, length: { maximum: 2048 }, presence: true
  validates :user_agent, length: { maximum: 2048 }
  validates :details, length: { maximum: 2**16 }
  validates_inclusion_of :javascript_enabled, in: [true, false]
  validates_inclusion_of :personal_information_status, in: %w[suspected absent], allow_nil: true
  validates_inclusion_of :is_actionable, in: [true, false]
  validates_presence_of :reason_why_not_actionable, unless: -> { is_actionable }

  scope :free_of_personal_info, -> {
    where(personal_information_status: "absent")
  }
  scope :only_actionable, -> { where(is_actionable: true) }
  scope :most_recent_first, -> { order(created_at: :desc) }
  scope :most_recent_last, -> { order(created_at: :asc) }
  scope :created_between_days, -> (first_date, last_date) { where(created_at: first_date..last_date.at_end_of_day) }
  scope :for_organisation_slug, -> (slug) { joins(:organisations).where(organisations: { slug: slug }) }
  scope :for_document_type, ->(document_type) { joins(:content_item).where(content_items: { document_type: document_type }) }

  scope :matching_path_prefixes, ->(paths) do
    if paths.present?
      similar_to = paths.map { |p| "#{p}%" }
      where(similar_to.map { "anonymous_contacts.path LIKE ?" }.join(" OR "), *similar_to)
    end
  end

  scope :for_query_parameters, ->(options={}) do
    path_prefixes = options[:path_prefixes]
    from = options[:from] || Date.new(1970)
    to = options[:to] || Date.today
    organisation_slug = options[:organisation_slug]
    document_type = options[:document_type]

    query = only_actionable.
      free_of_personal_info.
      created_between_days(from, to)

    query = query.matching_path_prefixes(path_prefixes) if path_prefixes.present?
    query = query.for_organisation_slug(organisation_slug) if organisation_slug
    query = query.for_document_type(document_type) if document_type

    query
  end

  MAX_PAGES = 200
  PAGE_SIZE = 50

  def self.deduplicate_contacts_created_between(interval)
    contacts = where(created_at: interval).order("created_at asc")
    deduplication_attribute_names = attribute_names - %w[id created_at updated_at]
    duplicate_detector = DuplicateDetector.new(deduplication_attribute_names)
    contacts.each do |contact|
      if duplicate_detector.duplicate?(contact)
        contact.mark_as_duplicate
        contact.save!
      end
    end
  end

  def url
    Plek.new.website_root + (path || "")
  end

  def mark_as_duplicate
    self.is_actionable = false
    self.reason_why_not_actionable = "duplicate"
    self
  end

private

  def detect_personal_information
    self.personal_information_status ||= personal_info_present? ? "suspected" : "absent"
  end

  def personal_info_present?
    free_text_fields = [self.details, self.what_wrong, self.what_doing]
    free_text_fields.any? { |text| FieldWhichMayContainPersonalInformation.new(text).include_personal_info? }
  end
end
