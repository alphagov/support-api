#!/usr/bin/env groovy

library("govuk")

node {
  govuk.setEnvar("TEST_DATABASE_URL", "postgresql://postgres@127.0.0.1:54313/support-api-test")

  govuk.buildProject(
    overrideTestTask: {
      stage("Run custom tests") {
        govuk.runRakeTask("ci:setup:rspec default")
      }
    },
    brakeman: true,
  )
}
