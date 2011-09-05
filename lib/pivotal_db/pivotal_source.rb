module PivotalDb

  module PivotalSource

    def self.included(base)
      base.extend(ClassMethods)
      
      base.class_eval do
        property :updated_from_datasource, DateTime
      end
    end

    def find_datasource
      raise NotImplementedError
    end
    
    def datasource
      @datasource ||= find_datasource
    end

    def datasource=(ds)
      @datasource = ds
    end

    def pull
      update_from_datasource
      self.updated_from_datasource = Time.now
      self.save
    end
    
    private

    def update_from_datasource
      raise NotImplementedError      
    end

    module ClassMethods
    end

  end

end
