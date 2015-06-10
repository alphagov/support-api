class ContentItem < ActiveRecord::Base
  has_and_belongs_to_many :organisations
  has_many :problem_reports, class_name: "ProblemReport"
  has_many :anonymous_contacts
  validates :path, presence: true

  before_create :fetch_organisations, unless: ->(content_item) { content_item.organisations.present? }

  scope :for_organisation, ->(organisation) {
    joins(:organisations).
    where(organisations: { id: organisation.id})
  }

  def self.summary(ordering="last_7_days")
    midnight_last_night = Date.today.to_time(:utc)
    ordering_mode = ordering == "path" ? "ASC" : "DESC"

    last_7_days = sum_column(from: midnight_last_night - 7.days, to: midnight_last_night)
    last_30_days = sum_column(from: midnight_last_night - 30.days, to: midnight_last_night)
    last_90_days = sum_column(from: midnight_last_night - 90.days, to: midnight_last_night)

    query = joins(:anonymous_contacts).
      select("content_items.path as path").
      select("#{last_7_days} AS last_7_days").
      select("#{last_30_days} AS last_30_days").
      select("#{last_90_days} AS last_90_days").
      where("anonymous_contacts.created_at > ?", midnight_last_night - 90.days).
      group("content_items.id").
      having("#{last_7_days} + #{last_30_days} + #{last_90_days} > 0").
      order("#{ordering} #{ordering_mode}")

    connection.
      select_all(query).
      map(&:symbolize_keys).
      map { |row| integers_for_sum_columns(row) }
  end

private
  def self.sum_column(options)
    "SUM(
       CASE WHEN anonymous_contacts.created_at BETWEEN '#{options[:from].to_s(:db)}' AND '#{options[:to].to_s(:db)}' THEN 1
            ELSE 0
            END
        )"
  end

  def fetch_organisations
    self.organisations = Organisation.for_path(path)
  end

  def self.integers_for_sum_columns(row)
    # the pg ActiveRecord adapter returns strings, even for SUM columns
    # see http://stackoverflow.com/questions/12571215/connection-select-value-only-returns-strings-in-postgres-with-pg-gem
    Hash[row.map {|key,value| [key, (key == :path ? value : value.to_i)] }]
  end
end
