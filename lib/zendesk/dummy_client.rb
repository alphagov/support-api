require "zendesk_api/error"

module Zendesk
  class DummyClient
    attr_reader :ticket, :users

    def initialize(options)
      @logger = options[:logger]
      @ticket = DummyTicket.new(@logger)
      @users = DummyUsers.new(@logger)
    end
  end

  class DummyTicket
    attr_reader :options

    def initialize(logger)
      @logger = logger
    end

    def create!(options)
      @options = options
      if should_raise_error?
        @logger.info("Simulating Zendesk ticket creation failure: #{options.inspect}")
        raise ZendeskAPI::Error::RecordInvalid.new(body: { "details" => "sample error message from Zendesk" })
      else
        @logger.info("Zendesk ticket created: #{options.inspect}")
      end
    end

  protected

    def should_raise_error?
      description =~ /break_zendesk/ or comment =~ /break_zendesk/
    end

    def description
      @options[:description]
    end

    def comment
      @options[:comment][:value] unless @options[:comment].nil?
    end
  end

  class DummyUsers
    def initialize(logger)
      @logger = logger
    end

    def search(_attributes)
      []
    end

    def suspended?(_user_email)
      false
    end

    def create_or_update_user(new_attributes)
      @logger.info("Zendesk user created or updated: #{new_attributes.inspect}")
    end
  end
end
