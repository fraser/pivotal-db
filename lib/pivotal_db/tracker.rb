require 'data_mapper'
require 'pivotal_tracker'

module PivotalDb
  class Tracker
    
    def initialize(options = {})

      @api_token = options[:api_token]
      @project_id = options[:project_id]
      @db_file = File.expand_path(options[:db_file])

      raise ArgumentError, "requires api_token, project_id, and db_file" unless @api_token && @project_id && @db_file

      DataMapper::Model.raise_on_save_failure = true

      DataMapper.setup(:default, 'sqlite://' + @db_file)

      DataMapper.repository(:default).adapter.resource_naming_convention =
        DataMapper::NamingConventions::Resource::UnderscoredAndPluralizedWithoutModule
      DataMapper.finalize
      DataMapper.auto_upgrade!
      
    end

    def pull

      pull_start = Time.now
      PivotalTracker::Client.token = @api_token
      PivotalTracker::Client.use_ssl = true
      project_ds = PivotalTracker::Project.find(@project_id)
      project = Project.first_or_create(:id => project_ds.id)
      
      project.datasource = project_ds
      project.pull
      
      # destroy stale records
      project.stories.all(:updated_from_datasource.lt => pull_start).destroy
      project.notes.all(:updated_from_datasource.lt => pull_start).destroy
    end

    def regexp(exp)
      rexp = Regexp.new(/.*#{exp}.*/mi)
      project = Project.first(:id => @project_id)
      found = []
      project.stories.all(:order => [:story_created_at.desc]).each do |story|
        if story.name.match(rexp) || story.description.match(rexp)
          found << story
        end
      end

      project.notes.all(:order => [:noted_at.desc]).each do |note|
        if note.text.match(rexp)
          found << note.story
        end
      end
      found
    end

  end
end
