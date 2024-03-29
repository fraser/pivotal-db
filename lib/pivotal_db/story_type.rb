module PivotalDb
  class StoryType
    
    include DataMapper::Resource
    
    property :id, Serial
    property :name, String
    property :created_at, DateTime
    property :updated_at, DateTime
    
    has n, :stories
    
  end
end
