require 'thor'

module PivotalDb
  class CLI < Thor

    desc "stats", "stats"
    def stats
      tracker = Tracker.new(Settings[Settings[:project]])
      puts "Projects: #{Project.all.count}"
      puts "Stories: #{Story.all.count}"
      puts "Notes: #{Note.all.count}"
    end

    desc "pull", "pull updates from pivotal tracker"
    def pull
      begin
        Tracker.new(Settings[Settings[:project]]).pull
      rescue DataMapper::SaveFailureError => e
          p e.resource.errors
      end
    end

    desc "random", "return a random incomplete story for review"
    def random
      tracker = Tracker.new(Settings[Settings[:project]])
      puts
      puts tracker.random
      puts
    end

    desc "search", "search for the given term in the stories"
    def search(term)
      found = Tracker.new(Settings[Settings[:project]]).search(term)
      puts "#{found.count} Results"
      found.each do |story|
        puts
        puts story.to_s(:brief)
        puts
      end
    end

    desc "show", "show a particular story by ID or URL"
    def show(story_id)
      tracker = Tracker.new(Settings[Settings[:project]])
      story_id = story_id.gsub(/.*\//, "")
      story = Story.get(story_id)
      if story
        puts story.to_s(:detailed)
      else
        puts "No story found"
      end
    end
      
  end
end
