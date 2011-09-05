module PivotalDb
  class Labeling
    
    include DataMapper::Resource
    
    property :id, Serial
    property :created_at, DateTime
    property :updated_at, DateTime

    belongs_to :story
    belongs_to :label

  end
end
