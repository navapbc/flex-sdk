require "rails/generators"

# Generator for creating business process files with standardized templates
module Flex
  module Generators
    # Generator for creating business process files with standardized templates
    class BusinessProcessGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      class_option :case, type: :string, desc: "(optional) Case class name. Ex: MedicaidCase"
      class_option :application_form, type: :string, desc: "(optional) Application form name. Ex: MedicaidApplicationForm"
      class_option :skip_generating_application_form, type: :boolean, default: false, desc: "Skip application form generation check"
      class_option :force_generating_application_form, type: :boolean, default: false, desc: "Generate application form without prompting"

      APPLICATION_FORM_SUFFIX = "ApplicationForm"

      def check_application_form_exists
        return if options[:skip_generating_application_form]
        return if @application_form_checked

        @application_form_checked = true
        app_form_class = application_form_name
        unless app_form_class.safe_constantize.present?
          if should_generate_application_form?(app_form_class)
            base_name = app_form_class.end_with?(APPLICATION_FORM_SUFFIX) ? app_form_class[0...-APPLICATION_FORM_SUFFIX.length] : app_form_class
            generate("flex:application_form", base_name)
          end
        end
      end

      def create_business_process_file
        full_file_path = File.join(destination_root, business_process_file_path)
        if File.exist?(full_file_path)
          raise "Business process file already exists at #{business_process_file_path}"
        end

        check_application_form_exists
        template "business_process.rb.tt", business_process_file_path
      end

      def update_application_config
        application_rb_path = File.join(destination_root, "config/application.rb")
        content = File.read(application_rb_path)

        start_listening_call = "    #{business_process_name}BusinessProcess.start_listening_for_events"

        if content.include?("config.after_initialize")
          if content.include?(start_listening_call.strip)
            return
          end

          content = content.gsub(/(config\.after_initialize\s+do(?:\s*\|[^|]*\|)?\s*\n)(.*?)(\n\s*end)/m) do |match|
            opening = $1
            existing_content = $2
            closing = $3

            if existing_content.strip.empty?
              "#{opening}#{start_listening_call}#{closing}"
            else
              "#{opening}#{existing_content}\n#{start_listening_call}#{closing}"
            end
          end
        else
          # Find the Application class and insert before its closing end
          # Look for "class Application < Rails::Application" and find its matching end
          class_start = content.index(/class Application < Rails::Application/)
          if class_start
            # Find all 'end' statements after the class declaration
            remaining_content = content[class_start..-1]
            lines = remaining_content.split("\n")

            # Find the line with the Application class end (should be before module end)
            application_end_line_index = nil
            indent_level = 0

            lines.each_with_index do |line, index|
              if line.strip.start_with?("class Application")
                indent_level = 1
              elsif line.strip == "end" && indent_level > 0
                indent_level -= 1
                if indent_level == 0
                  application_end_line_index = index
                  break
                end
              end
            end

            if application_end_line_index
              # Insert before the Application class end
              before_lines = lines[0...application_end_line_index]
              after_lines = lines[application_end_line_index..-1]

              after_initialize_lines = [
                "",
                "    config.after_initialize do",
                "#{start_listening_call}",
                "    end"
              ]

              new_lines = before_lines + after_initialize_lines + after_lines
              new_remaining_content = new_lines.join("\n")
              content = content[0...class_start] + new_remaining_content
            else
              raise "Could not find Application class end to insert config.after_initialize block"
            end
          else
            raise "Could not find Application class to insert config.after_initialize block"
          end
        end

        File.write(application_rb_path, content)
      end

      private

      def business_process_name
        name.classify
      end

      def file_name
        name.underscore
      end

      def business_process_file_path
        "app/business_processes/#{file_name}_business_process.rb"
      end

      def case_name
        options[:case] || "#{business_process_name}Case"
      end

      def application_form_name
        options[:application_form] || "#{business_process_name}ApplicationForm"
      end

      def should_generate_application_form?(app_form_class)
        options[:force_generating_application_form] || yes?("Application form #{app_form_class} does not exist. Generate it? (y/n)")
      end
    end
  end
end
