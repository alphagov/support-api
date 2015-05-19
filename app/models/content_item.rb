class ContentItem < ActiveRecord::Base
  has_and_belongs_to_many :organisations
  has_many :problem_reports, class_name: "ProblemReport"
  has_many :anonymous_contacts
  validates :path, presence: true

  before_create :fetch_organisations, unless: ->(content_item) { content_item.organisations.present? }

  scope :for_organisation, ->(organisation) {
    joins(:organisations).
    where("organisations.id = ?", organisation.id)
  }

  def self.summary
    midnight_last_night = Date.today.to_time(:utc)

    joins(:anonymous_contacts).
    select("content_items.path as path").
    select(sum_column(from: midnight_last_night - 7.days, to: midnight_last_night, column_name: "last_7_days")).
    select(sum_column(from: midnight_last_night - 30.days, to: midnight_last_night, column_name: "last_30_days")).
    select(sum_column(from: midnight_last_night - 90.days, to: midnight_last_night, column_name: "last_90_days")).
    group("content_items.id").
    reject {|r| [ r.last_7_days, r.last_30_days, r.last_90_days ].sum == 0 }.
    map { |r|
      {
        path: r.path,
        last_7_days: r.last_7_days,
        last_30_days: r.last_30_days,
        last_90_days: r.last_90_days
      }
    }
  end

private
  def self.sum_column(options)
    "SUM(
       CASE WHEN anonymous_contacts.created_at BETWEEN '#{options[:from].to_s(:db)}' AND '#{options[:to].to_s(:db)}' THEN 1
            ELSE 0
            END
        ) AS #{options[:column_name]}"
  end

  def fetch_organisations
    self.organisations = Organisation.for_path(path)
  end
end
