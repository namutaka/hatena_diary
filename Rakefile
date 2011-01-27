#
# HatenaDiary
#
require File.join(File.dirname(__FILE__), 'hatena_diary')
client = nil

task :default => :environment

task :environment do
  require "highline"

  hatena_id = ENV['ID']
  passwd = ENV['PW']

  if hatena_id.nil? or hatena_id.empty?
    hatena_id = HighLine.new.ask('ID: ')
  end

  if passwd.nil? or passwd.empty?
    passwd = HighLine.new.ask('Password: ') {|q| q.echo = '*' }
  end

  client = HatenaDiary::Client.new hatena_id, passwd
end

namespace :draft do
  task :delete => :environment do
    HatenaDiary::Entry.entry_files do |f|
      HatenaDiary::Entry.delete(f)
    end
  end

  task :pull => :delete do
    client.list(false).each do |e|
      e.save
    end
  end

  task :push => :environment do
    HatenaDiary::Entry.entry_files do |f|
      entry = HatenaDiary::Entry.load(f)
      client.update(entry)
    end
  end
end

