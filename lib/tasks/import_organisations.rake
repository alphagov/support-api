require 'organisation_importer'
require 'distributed_lock'

namespace :api_sync do
  desc "Imports all organisations from the Whitehall Organisations API"
  task :import_organisations => :environment do
    DistributedLock.new('import_organisations').lock do
      OrganisationImporter.new.run
    end
  end
end
