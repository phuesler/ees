module Ees
  module Generators
    class << self

      def generate_project options
        template_path = File.join( Ees::Api.template_path, "project", ".")
        project_path  = File.join( options[:path], options[:argument] )

        FileUtils.mkdir( project_path )
        FileUtils.cp_r( template_path, project_path )
       end

      def generate_app options
        unless Dir.exists?( File.join( options[:path], "apps" ) )
          puts "Run this command from the project root"
          return
        end

        template_path = File.join( Ees::Api.template_path, "app", ".")
        app_path = File.join( options[:path], "apps", options[:argument] )

        if Dir.exists?( app_path )
          puts "Application already exists in #{app_path}"
          return
        end

        FileUtils.mkdir( app_path )
        FileUtils.cp_r( template_path, app_path )

        render_erb_files( :name => options[:argument], :path => app_path )
      end

      def generate_behavior options
        current_path_segements = Dir.pwd.split( File::SEPARATOR )

        unless current_path_segements[-2] == "apps"
          puts "Run this command inside of an app directory"
          return
        end

        render_behavior_erb(
          :behavior   => options[:sub_command],
          :name       => options[:argument],
          :path       => Dir.pwd,
          :arguments  => options[:sub_arguments]
        )
      end

      private

      def render_erb_files options
        app_name        = options[:name]
        templates_path  = File.join( options[:path], "src" )

        Dir.entries( templates_path ).each do |filename|
          next if filename =~ /^\./

          template_path = File.join( templates_path, filename )
          template      = File.read( template_path )
          new_filename  = File.join( templates_path, filename.sub(/\.erb$/, "") )

          File.open( template_path, "w+" ) do |file|
            file.write ERB.new( template ).result( binding )
          end

          FileUtils.mv( template_path, new_filename )
        end

      end

      def render_behavior_erb options
        name      = options[:name]
        arguments = options[:arguments]

        template_path = File.join(
          Ees::Api.template_path, "behaviors", "#{options[:behavior]}.erb"
        )

        template          = ERB.new( File.read( template_path ) )
        destination_path  = File.join( Dir.pwd, "src", "#{name}.erl" )

        File.open( destination_path, "w+" ) do |file|
          file.write( template.result( binding ) )
        end
      end
    end
  end
end