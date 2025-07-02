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
  validates :javascript_enabled, inclusion: { in: [true, false] }
  validates :personal_information_status, inclusion: { in: %w[suspected absent], allow_nil: true }
  validates :is_actionable, inclusion: { in: [true, false] }
  validates :reason_why_not_actionable, presence: { unless: -> { is_actionable } }

  scope :free_of_personal_info,
        lambda {
          where(personal_information_status: "absent")
        }
  scope :only_actionable, -> { where(is_actionable: true) }
  scope :most_recent_first, -> { order(created_at: :desc) }
  scope :most_recent_last, -> { order(created_at: :asc) }
  scope :created_between_days, ->(first_date, last_date) { where(created_at: first_date..last_date.at_end_of_day) }
  scope :for_organisation_slug, ->(slug) { joins(:organisations).where(organisations: { slug: }) }
  scope :for_document_type, ->(document_type) { joins(:content_item).where(content_item: { document_type: }) }

  scope :matching_path_prefixes,
        lambda { |paths|
          if paths.present?
            similar_to = paths.map { |p| "#{p}%" }
            where(similar_to.map { "anonymous_contacts.path LIKE ?" }.join(" OR "), *similar_to)
          end
        }

  scope :for_query_parameters,
        lambda { |options = {}|
          path_prefixes = options[:path_prefixes]
          from = options[:from] || Date.new(1970)
          to = options[:to] || Time.zone.today
          organisation_slug = options[:organisation_slug]
          document_type = options[:document_type]

          query = only_actionable
            .free_of_personal_info
            .created_between_days(from, to)

          query = query.matching_path_prefixes(path_prefixes) if path_prefixes.present?
          query = query.for_organisation_slug(organisation_slug) if organisation_slug
          query = query.for_document_type(document_type) if document_type

          query
        }

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

  def self.summary(order_by, relation: nil)
    last_7_counts = count_in_last_n_days(7, relation:)
    last_30_counts = count_in_last_n_days(30, relation:)
    last_90_counts = count_in_last_n_days(90, relation:)

    last_90_counts.keys.map { |path|
      next if last_90_counts[path].zero?

      {
        path:,
        last_7_days: last_7_counts.fetch(path, 0),
        last_30_days: last_30_counts.fetch(path, 0),
        last_90_days: last_90_counts.fetch(path, 0),
      }
    }
      .compact
      .sort_by { _1[order_by.to_sym] }
      .tap { |result| result.reverse! unless order_by == "path" }
  end

  def self.count_in_last_n_days(last_n_days, relation:)
    (relation || all)
      .joins(:content_item)
      .created_between_days(
        Time.zone.today - last_n_days.days,
        Time.zone.yesterday,
      )
      .group("content_item.path")
      .count
  end
  private_class_method :count_in_last_n_days

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
    free_text_fields = [details, what_wrong, what_doing]
    free_text_fields.any? { |text| FieldWhichMayContainPersonalInformation.new(text).include_personal_info? }
  end
end
