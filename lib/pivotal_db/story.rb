module PivotalDb
  class Story
    
    include DataMapper::Resource
    include PivotalSource
    
    property :id, Serial
    property :name, Text
    property :description, Text
    property :estimate, Integer
    property :story_created_at, DateTime
    property :updated_from_pivotal_source, Boolean
    property :created_at, DateTime
    property :updated_at, DateTime

    belongs_to :project
    belongs_to :story_state
    belongs_to :story_type
    belongs_to :requested_by, 'Person', :required => false
    belongs_to :owned_by, 'Person', :required => false

    has n, :notes, :constraint => :destroy
    has n, :labelings, :constraint => :destroy
    has n, :labels, :through => :labelings
    
    def find_datasource
      PivotalTracker::Story.find(self.id, self.project_id)
    end

    def update_from_datasource

      self.project ||= Project.first(:id => datasource.project_id)

      requested_by = self.project.people.first(:name => datasource.requested_by)
      owned_by = datasource.owned_by.nil? ? nil : self.project.people.first(:name => datasource.requested_by)
          
      labels = (datasource.labels || "").split(",").map{|label| Label.first_or_create(:name => label.strip)}
          
      story_state = StoryState.first_or_create(:name => datasource.current_state)
      story_type = StoryType.first_or_create(:name => datasource.story_type)
          
      self.attributes = {
        :id => datasource.id,
        :project_id => datasource.project_id,
        :requested_by => requested_by,
        :owned_by => owned_by,
        :story_type => story_type,
        :story_state => story_state,
        :labels => labels,
        :name => datasource.name, 
        :description => datasource.description, 
        :estimate => datasource.estimate,
        :story_created_at => datasource.created_at
      }
      self.save
      
      pull_notes
    end

    def pull_notes
      datasource.notes.all.each do |note_ds|
        note = self.notes.first(:id => note_ds.id) || self.notes.new(:id => note_ds.id)
        note.datasource = note_ds
        note.pull
      end
    end

    def to_s(detail_level = :summary)
      detail_levels = {:brief => 1, :summary => 2, :detailed => 3}
      detail = detail_levels[detail_level]

      requested_by_name = self.requested_by ? self.requested_by.name : ""
      owned_by_name = self.owned_by ? " => " + self.owned_by.name : ""
      str = ""
      str += "https://www.pivotaltracker.com/story/show/#{self.id}\n"
      str += "#{self.name}\n"
      str += self.story_type.name + ": " + self.labels.map{|label| label.name}.join(", ") + "\n"
      str += requested_by_name + owned_by_name + ": " + self.story_created_at.to_s + "\n"
      
      if detail_levels[:summary] <= detail
        str += "\n#{self.description}\n"
      end

      sorted_notes = self.notes.all(:order => [:noted_at.asc])
      if detail_levels[:detailed] <= detail
        sorted_notes.each do |note|
          str += note.to_s + "\n"
        end
      elsif detail_levels[:summary] <= detail
        unless sorted_notes.blank?
          str += "\n#{sorted_notes.count} Notes\n"
          note = sorted_notes.last
          str += "\nLatest Note:\n"
          str += note.to_s
        end
      end
      str
    end

  end
end
