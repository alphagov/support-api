require "open3"

# Runs the vendored profanity filter (vendor/better_profanity) over
# free-text fields using a python3 subprocess (script/censor_batch.py),
# so Zendesk tickets and the govuk-feedback-processing pipeline produce
# identical masking by construction, using the same library and wordlist.
#
# Takes all of a ticket's texts in one call rather than one at a time:
# interpreter startup and wordlist loading dominate each subprocess run, so
# callers (Zendesk::Ticket#batch_mask) batch every field into a single call.
#
# Failure policy: fail-open. ZendeskTicketJob is not idempotent (a raise
# would mean a Sidekiq retry and a duplicate ticket), so this process must
# never raise. On any failure the original texts are returned unmasked and
# the profanity_mask_error metric is incremented.
module ProfanityFilter
  SCRIPT = "script/censor_batch.py".freeze

  class << self
    def mask(texts)
      return texts if texts.empty?

      stdout, status = Open3.capture2(python, script_path, stdin_data: JSON.generate(texts:))

      unless status.success?
        report_failure("censor_batch.py exited with status #{status.exitstatus}")
        return texts
      end

      JSON.parse(stdout, symbolize_names: true).fetch(:masked)
    rescue StandardError => e
      report_failure("#{e.class}: #{e.message}")
      texts
    end

  private

    def python
      ENV.fetch("PROFANITY_PYTHON", "python3")
    end

    def script_path
      root = defined?(Rails) ? Rails.root : Pathname.new(__dir__).join("..")
      File.expand_path(SCRIPT, root)
    end

    def report_failure(message)
      GovukStatsd.increment("govuk_zendesk.profanity_mask_error")
      Rails.logger.warn("Profanity masking failed, passing text through unmasked: #{message}")
    end
  end
end
