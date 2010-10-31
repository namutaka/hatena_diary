#
# HatenaDiary
#
require File.join(File.dirname(__FILE__), 'hatena_diary')
client = nil

task :default => :environment

task :environment do
  hatena_id = ENV['ID']
  passwd = ENV['PW']
  raise "Invalid Argument" unless hatena_id

  client = HatenaDiary::Client.new hatena_id, passwd
end

namespace :draft do
  task :pull => :environment do
    client.list(false).each do |e|
      e.save
    end
  end

  task :push => :environment do
    Dir["tag:*.txt"].each do |f|
      entry = HatenaDiary::Entry.load(f)
      client.update(entry)
    end
  end
end

