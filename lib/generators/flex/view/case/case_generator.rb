require "rails/generators"

module Flex
  module Generators
    module View
      # Generator for creating Flex Case view templates with standardized layouts
      # and commented variable replacement instructions
      class CaseGenerator < Rails::Generators::NamedBase
        source_root File.expand_path("templates", __dir__)

        argument :view_types, type: :array, default: [], desc: "View types to generate (index, show)"

        def validate_view_types
          if view_types.empty?
            say "Error: You must provide at least one view type (index, show)", :red
            say "Example: bin/rails generate flex:view:case #{name} index show", :yellow
            exit(1)
          end
        end

        def check_files_exist
          target_files = []
          target_files << "app/views/#{name.underscore}/index.html.erb" if view_types.include?("index")
          target_files << "app/views/#{name.underscore}/show.html.erb" if view_types.include?("show")

          target_files.each do |file_path|
            full_file_path = File.join(destination_root, file_path)
            if File.exist?(full_file_path)
              raise "File already exists at #{file_path}"
            end
          end
        end

        def create_view_directory
          empty_directory "app/views/#{name.underscore}"
        end

        def create_index_view
          return unless view_types.include?("index")
          template "index.html.erb", "app/views/#{name.underscore}/index.html.erb"
        end

        def create_show_view
          return unless view_types.include?("show")
          template "show.html.erb", "app/views/#{name.underscore}/show.html.erb"
        end
      end
    end
  end
end
