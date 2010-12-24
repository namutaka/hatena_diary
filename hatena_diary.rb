require 'rubygems'
require 'atomutil'

module HatenaDiary
  class HatenaAtomClient < Atompub::Client

    def publish_entry(uri)
      @hatena_publish = true
      update_resource(uri, ' ', Atom::MediaType::ENTRY.to_s)
    ensure
      @hatena_publish = false
    end

  private
    def set_common_info(req)
      req['X-Hatena-Publish'] = 1 if @hatena_publish
      super(req)
    end
  end

  class Client
    def initialize(hatena_id, password)
      auth = Atompub::Auth::Wsse.new :username => hatena_id, :password => password
      @client = HatenaAtomClient.new :auth => auth

      @hatena_id = hatena_id
      @service = @client.get_service 'http://d.hatena.ne.jp/%s/atom' % @hatena_id
    end

    def list(is_public = true)
      @client.get_feed(collection_uri(is_public)).
          entries.map { |e| Entry.new e }
    end

    def create(entry, is_public = true)
      @client.create_entry(collection_uri(is_public), entry.entry)
    end

    def update(entry)
      @client.update_entry( entry.entry.edit_link, entry.entry )
    end

    def delete(entry)
      @client.delete_entry( entry.entry.edit_link )
    end

  private
    def collection_uri(is_public)
      is_public ? public_collection_uri : private_collection_uri
    end

    def public_collection_uri
      @service.workspace.collections[1].href
    end

    def private_collection_uri
      @service.workspace.collections[0].href
    end
  end


  class Entry
    def self.new(params = nil)
      obj = super(params)
      yield(obj.entry) if block_given?
      obj
    end

    def self.load(file_path)
      id = File.basename(file_path, '.*')
      lines = IO.readlines(file_path)

      self.new do |e|
        e.id = id

        e.title = lines.shift
        e.edit_link = lines.shift
        lines.shift
        e.content = lines.join
      end
    end


    attr_accessor :entry

    def initialize(params = nil)
      if params.is_a?(Atom::Entry)
        @entry = params
      else
        @entry = Atom::Entry.new(params||{})
      end
    end

    def save(path = nil)
      file_path = @entry.id + ".txt"
      file_path = File.join(path, file_path) if path
      open(file_path, 'w') do |f|
        f.puts(@entry.title || "")
        f.puts(@entry.edit_link)
        f.puts('')
        f.write(@entry.content.body)
      end
    end
  end
end

class Atom::Entry
  alias :title_without_hatena= :title=
  def title=(str)
    text_node = REXML::Text.new(str, true, nil, true)
    self.title_without_hatena = text_node.to_s
  end

  alias :content_without_hatena= :content=
  def content=(str)
    text_node = REXML::Text.new(str, true, nil, false)
    self.content_without_hatena = Atom::Content.new(
        :body => text_node.to_s, :type => 'text')
  end
end

module REXML
  class Text
    def clone
      return Text.new(self.to_s, true, nil, true)
    end
  end
end

