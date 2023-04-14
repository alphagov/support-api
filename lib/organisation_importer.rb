require "gds_api"

class OrganisationImporter
  def run
    Rails.logger.info "Fetching all organisations from the Organisation API..."
    organisations = organisations_api.organisations.with_subsequent_pages.to_a
    Rails.logger.info "Loaded #{organisations.size} organisations"

    organisations.each do |organisation|
      create_or_update_organisation(organisation)
    end

    Rails.logger.info "Import complete"
  end

private

  def create_or_update_organisation(organisation_from_api)
    organisation_attrs = {
      title: organisation_from_api["title"],
      slug: organisation_from_api["details"]["slug"],
      acronym: organisation_from_api["details"]["abbreviation"],
      govuk_status: organisation_from_api["details"]["govuk_status"],
      web_url: organisation_from_api["web_url"],
      content_id: organisation_from_api["details"]["content_id"],
    }

    content_id = organisation_from_api["details"]["content_id"]
    existing_organisation = Organisation.find_by(content_id:)

    if existing_organisation.present?
      existing_organisation.update!(organisation_attrs)
      Rails.logger.info "Updated #{existing_organisation.title}"
    else
      Organisation.create!(organisation_attrs)
      Rails.logger.info "Created #{organisation_attrs[:title]}"
    end
  end

  def organisations_api
    @organisations_api ||= GdsApi.organisations
  end
end
