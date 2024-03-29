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
      project.stories.all(:updated_from_datasource_at.lt => pull_start).destroy
      project.notes.all(:updated_from_datasource_at.lt => pull_start).destroy
    end

    def random
      project = Project.first(:id => @project_id)
      state_ids = StoryState.all(:name => ["unscheduled", "unstarted", "started", "rejected"]).map{|state| state.id}
      story_id = DataMapper.repository(:default).adapter.select('SELECT id FROM stories WHERE story_state_id IN ? ORDER BY RANDOM() LIMIT 1', state_ids).first
      Story.get(story_id)
    end

    def search(term, states = nil)
      project = Project.first(:id => @project_id)
      if states.nil?
        state_ids = StoryState.all.map{|state| state.id}
      else
        state_ids = StoryState.all(:name => states).map{|state| state.id}
      end
      story_ids = DataMapper.repository(:default).adapter.select('SELECT stories.id FROM stories LEFT JOIN notes ON stories.id = notes.story_id WHERE story_state_id IN ? AND (name LIKE ? OR description LIKE ? OR notes.text LIKE ?)', state_ids, "%#{term}%", "%#{term}%", "%#{term}%")
      Story.all(:id => story_ids)
    end

  end
end
