class RemoveBlankDates < ActiveRecord::Migration
  def up
    records = AnonymousContact.where("created_at = '0000-00-00 00:00:00' OR
                                      updated_at = '0000-00-00 00:00:00'")

    # At time of writing, there were only 3 of these.
    if records.size > 10
      Rails.logger.warn "Migration would have removed #{records.size} records. " +
       "Cowardly refusing to do anything."
    else
      records.each(&:destroy)
    end
  end
end
