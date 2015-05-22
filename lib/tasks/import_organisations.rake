require 'organisation_importer'

namespace :api_sync do
  desc "Imports all organisations from the Whitehall Organisations API"
  task :import_organisations => :environment do
    OrganisationImporter.new.run
  end
end
