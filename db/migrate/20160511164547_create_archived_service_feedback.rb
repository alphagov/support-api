class CreateArchivedServiceFeedback < ActiveRecord::Migration
  def change
    create_table :archived_service_feedbacks do |t|
      t.string :type
      t.string :slug
      t.integer :service_satisfaction_rating
      t.timestamps
    end
  end
end
