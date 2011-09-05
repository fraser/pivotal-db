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


    desc "regexp", "perform a regular expression search on stories"
    def regexp(exp)
      found = Tracker.new(Settings[Settings[:project]]).regexp(exp)
      found.each do |story|
        puts story
      end
    end

  end
end
