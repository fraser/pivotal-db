module PivotalDb
  class Membership
    
    include DataMapper::Resource
    include PivotalSource
    
    property :id, Serial
    property :created_at, DateTime
    property :updated_at, DateTime
    
    belongs_to :role
    belongs_to :project
    belongs_to :person

    def find_datasource
      self.project.datasource.memberships.all.find{|membership_ds| membership_ds == self.id}
    end

    def update_from_datasource

      role = Role.first_or_create(:name => datasource.role)

      person = Person.first(:email => datasource.email) || Person.new
      person.datasource = datasource
      person.pull

      self.attributes = {
        :id => datasource.id,
        :role => role,
        :person => person
      }
      self.save
    end

  end
end
