require 'set'
require 'time'

class ZendeskCleaner
  attr_reader :client, :users_with_existing_tickets, :tickets_to_delete, :users_to_delete

  def initialize(client, dry_run, groups = [])
    @client = client
    @dry_run = dry_run
    @groups = groups
    @users_with_existing_tickets = Set.new
    @tickets_to_delete = Set.new
    @users_to_delete = Set.new
  end

  def display_current_num_of_tickets_and_users
    puts "This Zendesk instance has #{@client.users.count} users and #{@client.tickets.count} tickets."
  end

  def how_many_things_have_we_deleted
    puts "We have deleted #{@users_to_delete.size} users and #{@tickets_to_delete.size} tickets."
  end

  def delete_old_tickets
    @client.tickets.all! do |ticket|
      users_with_existing_tickets.add(ticket.requester_id) if client.users.find!(id: ticket.requester_id)

      next unless @groups.include?(ticket.group_id)

      delete_tickets_older_than_a_year(ticket)
    end
  end

  # As we've already deleted tickets which have not been updated
  # for a year (`tickets_for_deletion`), their associations to users
  # should be gone too, meaning that `users_with_existing_tickets` will
  # only be the ones who have have been active within a year.
  def delete_old_users
    @client.users.all! do |user|
      if is_end_user?(user) &&
          is_not_in_an_org?(user) &&
          @users_with_existing_tickets.exclude?(user.id) &&
          has_been_active_within_a_year?(user)

        @users_to_delete.add(user.id)
        if @dry_run
          print '.'
        else
          user.destroy!
        end
      end
    end
  end

private

  def has_been_active_within_a_year?(user)
    if user.last_login_at
      return user.last_login_at < 1.year.ago.to_datetime
    end

    latest_update = user.updated_at || user.created_at
    latest_update < 1.year.ago.to_datetime
  end

  def delete_tickets_older_than_a_year(ticket)
    if is_closed?(ticket) && not_updated_for_a_year?(ticket)
      @tickets_to_delete.add(ticket.id)
      if @dry_run
        print '/'
      else
        ticket.destroy!
      end
    end
  end

  def is_closed?(ticket)
    ticket.status == 'closed'
  end

  def not_updated_for_a_year?(ticket)
    latest_update = ticket.updated_at || ticket.created_at
    latest_update < "2013-01-01T00:00:00+00:00".to_datetime
  end

  def is_end_user?(user)
    user.role.name == "end-user"
  end

  def is_not_in_an_org?(user)
    user.organisation_id.nil?
  end
end
