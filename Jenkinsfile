#!/usr/bin/env groovy

library("govuk")

node("postgresql-9.3") {
  govuk.buildProject(
    overrideTestTask: {
      stage("Run custom tests") {
        govuk.runRakeTask("ci:setup:rspec default")
      }
    },
    brakeman: true,
    rubyLintDiff: false,
  )
}
