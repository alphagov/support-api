#!/bin/bash -x

set -e

export RAILS_ENV=test
git clean -fdx
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

for db_type in mysql postgresql; do
  SUPPORT_API_DB_TYPE=$db_type bundle exec rake db:reset
  SUPPORT_API_DB_TYPE=$db_type bundle exec rake ci:setup:rspec default --trace
done
