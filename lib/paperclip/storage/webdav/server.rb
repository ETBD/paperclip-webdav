require 'uri'
require 'curb'
require "net/webdav/client"

module Paperclip
  module Storage
    module Webdav
      class Server
        def initialize credentials
          @client = Net::Webdav::Client.new(credentials[:url], username: credentials[:username], password: credentials[:password])
        end

        def file_exists? path
          @client.file_exists?(path)
        end

        def get_file remote_file_path, local_file_path
          @client.get_file(remote_file_path, local_file_path)
        end

        def put_file path, file
          @client.put_file(path, file, true)
        end

        def delete_file path
          @client.delete_file(path)
        end
      end
    end
  end
end
