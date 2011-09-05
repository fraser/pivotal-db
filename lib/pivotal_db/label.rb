module PivotalDb
  class Label
    
    include DataMapper::Resource
    
    property :id, Serial
    property :name, String
    property :created_at, DateTime
    property :updated_at, DateTime
    
    has n, :labelings, :constraint => :destroy
    has n, :stories, :through => :labelings
    
  end
end
