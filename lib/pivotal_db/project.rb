module PivotalDb

  class Project
    
    include DataMapper::Resource
    include PivotalSource

    property :id, Serial
    property :name, String
    property :created_at, DateTime
    property :updated_at, DateTime

    has n, :stories, :constraint => :destroy
    has n, :notes, :through => :stories
    has n, :memberships, :constraint => :destroy
    has n, :people, :through => :memberships

    def find_datasource
      PivotalTracker::Project.find(self.id)
    end

    def update_from_datasource

      self.attributes = {
        :name => datasource.name
      }
      self.save

      pull_memberships
      pull_stories
      
    end

    private

    def pull_memberships
      datasource.memberships.all.each do |membership_ds|
        membership = self.memberships.first(:id => membership_ds.id, :project => self) || Membership.new(:id => membership_ds.id, :project => self)
        membership.datasource = membership_ds
        membership.pull
      end
    end

    def pull_stories
      limit = 1000
      offset = 0
      while true
        found_stories = false
        datasource.stories.all(:offset => offset, :limit => limit).each do |story_ds|
          found_stories = true
          story = self.stories.first(:id => story_ds.id) || Story.new
          story.datasource = story_ds
          story.pull
        end
        break unless found_stories
        offset += limit
      end
    end

  end
end
