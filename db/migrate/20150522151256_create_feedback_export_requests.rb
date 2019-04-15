class CreateFeedbackExportRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :feedback_export_requests do |t|
      t.string :notification_email, null: false
      t.date :filter_from
      t.date :filter_to
      t.string :path_prefix
      t.string :filename
      t.datetime :generated_at, null: true
      t.timestamps null: false
    end
  end
end
