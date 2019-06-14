require 'zendesk_api'
require 'zendesk_cleaner'

namespace :zendesk do
  desc "Delete info in Zendesk about people who haven't contacted us in a year."
  task :delete_old_users_and_tickets, [] do |_, args|
    # Authenticate with Zendesk.
    client = ZendeskAPI::Client.new do |config|
      config.url = ENV['ZENDESK_URL']
      config.username = ENV['ZENDESK_USER_EMAIL']
      config.password = ENV['ZENDESK_USER_PASSWORD']

      config.retry = true
    end

    cleaner = ZendeskCleaner.new(client, ENV.has_key?('DRY_RUN'), args.extras.map(&:to_i))

    cleaner.display_current_num_of_tickets_and_users

    cleaner.delete_old_tickets

    cleaner.delete_old_users

    cleaner.how_many_things_have_we_deleted
  end
end
