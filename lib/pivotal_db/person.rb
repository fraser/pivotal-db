module PivotalDb
  class Person
    
    include DataMapper::Resource
    include PivotalSource
    
    property :id, Serial
    property :name, String
    property :email, String, :unique => true
    property :initials, String
    property :created_at, DateTime
    property :updated_at, DateTime
    
    has n, :notes, :child_key => [ :author_id ]
    has n, :requested_stories, :model => 'Story', :child_key => [ :requested_by_id ]
    has n, :owned_stories, :model => 'Story', :child_key => [ :owned_by_id ]

    def update_from_datasource
      self.attributes = {
        :name => datasource.name,
        :email => datasource.email,
        :initials => datasource.initials
      }
      self.save
    end

  end
end
