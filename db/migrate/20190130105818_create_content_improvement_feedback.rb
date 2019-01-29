class CreateContentImprovementFeedback < ActiveRecord::Migration[5.2]
  def change
    create_table :content_improvement_feedbacks do |t|
      t.string :description, null: false
      t.boolean :reviewed, null: false, default: false
      t.boolean :marked_as_spam, null: false, default: false
      t.string :personal_information_status
    end
  end
end
