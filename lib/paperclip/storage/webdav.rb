require "paperclip"
require "paperclip/storage/webdav/server"

module Paperclip
  module Storage
    module Webdav
      def self.extended base        
        base.instance_eval do
          if @options[:webdav_servers].blank?
            raise "Webdav servers not set."
          end
          if @options[:public_url].blank?
            raise "public url not set."
          end
          unless @options[:url].to_s.match(/^:public_url$/)
            @options[:path]  = @options[:path].gsub(/:url/, @options[:url]).gsub(/^:rails_root\/public\/system\//, '')
            @options[:url]   = ':public_url'
          end

          Paperclip.interpolates(:public_url) do |attachment, style|
            attachment.public_url(style)
          end unless Paperclip::Interpolations.respond_to? :public_url

        end
      end
      
      def exists? style_name = default_style
        if original_filename
          primary_server.file_exists? path(style_name)
        else
          false
        end
      end

      def flush_writes
        @queued_for_write.each do |style_name, file|
          servers.each do |server|
            server.put_file path(style_name), file
          end
          file.rewind
        end
        after_flush_writes
        @queued_for_write = {}
      end

      def flush_deletes
        @queued_for_delete.each do |path|
          servers.each do |server|
            server.delete_file path
          end
        end
        @queued_for_delete = []
      end

      def copy_to_local_file style, local_dest_path
        primary_server.get_file path(style), local_dest_path
      end
      
      def public_url style = default_style
        @options[:public_url] ||= URI.parse(@options[:webdav_servers].first[:url])
        URI.join(@options[:public_url], path(style)).to_s
      end
     
      private
 
      def servers
        @webdav_servers ||= begin
          servers = []
          @options[:webdav_servers].each do |credentials|
            servers << Server.new(credentials)
          end
          servers
        end
      end
      
      def primary_server
        servers.first
      end
    end
  end
end
