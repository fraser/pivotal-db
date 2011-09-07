
# Pivotal DB

Pull Pivotal Tracker stories into a local SQLite database.  No changes to the local DB will be reflected in Pivotal Tracker (this is not sync).

This provides a basic CLI (pivotal-db) along with a Ruby library.

## Installation

    gem install pivotal_db

## Configuration

Before starting, you'll have to add a configuration file at ~/.pivotal_db/config.yml like the following:

    default:
      project_id: 123
      api_token: secret
      db_file: ~/.pivotal_db/pivotal.db

Your API token can be found on Pivotal Tracker at https://www.pivotaltracker.com/profile.

## Usage

To see usage, run (without any arguments)

    pivotal-db
