module PivotalDb
  class Note
    
    include DataMapper::Resource
    include PivotalSource
    
    property :id, Serial
    property :noted_at, DateTime
    property :text, Text
    property :created_at, DateTime
    property :updated_at, DateTime

    belongs_to :story
    belongs_to :author, 'Person', :required => false

    def find_datasource
      self.story.datasource.notes.all.find{|note_ds| note_ds.id == self.id}
    end

    def update_from_datasource

      project = Project.first(datasource.project_id)
      author = project.people.first(:name => datasource.author)
      self.attributes = {
        :id => datasource.id,
        :story_id => datasource.story_id,
        :author => author,
        :noted_at => datasource.noted_at,
        :text => datasource.text
      }
      self.save

    end

  end
end
