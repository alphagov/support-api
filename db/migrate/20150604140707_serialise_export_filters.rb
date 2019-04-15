class SerialiseExportFilters < ActiveRecord::Migration[4.2]
  def up
    add_column :feedback_export_requests, :filters, :text

    FeedbackExportRequest.reset_column_information

    FeedbackExportRequest.all.each do |req|
      filters = {}
      filters[:from] = req.filter_from if req.filter_from
      filters[:to] = req.filter_to if req.filter_to
      filters[:path_prefix] = req.path_prefix if req.path_prefix
      req.update(filters: filters)
    end

    remove_column :feedback_export_requests, :filter_from
    remove_column :feedback_export_requests, :filter_to
    remove_column :feedback_export_requests, :path_prefix
  end

  def down
    add_column :feedback_export_requests, :path_prefix, :string
    add_column :feedback_export_requests, :filter_to, :date
    add_column :feedback_export_requests, :filter_from, :date

    FeedbackExportRequest.reset_column_information

    FeedbackExportRequest.all.each do |req|
      req.filter_from = req.filters[:from] if req.filters[:from]
      req.filter_to = req.filters[:to] if req.filters[:to]
      req.path_prefix = req.filters[:path_prefix] if req.filters[:path_prefix]
      req.save
    end

    remove_column :feedback_export_requests, :filters
  end
end
