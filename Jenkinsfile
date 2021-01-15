#!/usr/bin/env groovy

library("govuk")

node {
  govuk.buildProject(
    overrideTestTask: {
      stage("Run custom tests") {
        govuk.runRakeTask("ci:setup:rspec default")
      }
    },
    brakeman: true,
  )
}
