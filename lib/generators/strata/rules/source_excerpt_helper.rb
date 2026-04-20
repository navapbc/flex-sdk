# frozen_string_literal: true

module Strata
  module Generators
    # Helper methods for reading SDK source files and documentation sections.
    # Included in RulesGenerator to make helpers available in ERB template bindings.
    module SourceExcerptHelper
      def sdk_root
        Strata::Engine.root
      end

      # Reads a file relative to the SDK root. Returns content as a string.
      # Raises if the file does not exist.
      def read_sdk_file(relative_path)
        full_path = sdk_root.join(relative_path)
        raise "SDK file not found: #{relative_path} (looked at #{full_path})" unless File.exist?(full_path)
        File.read(full_path, encoding: "UTF-8").strip
      end

      # Extracts a markdown section by heading from a doc file in docs/.
      # Returns everything between the matched heading and the next heading
      # of the same or higher level. Returns empty string if heading not found.
      def excerpt_doc_section(doc_filename, section_heading)
        doc_path = sdk_root.join("docs", doc_filename)
        raise "Doc file not found: #{doc_filename} (looked at #{doc_path})" unless File.exist?(doc_path)

        content = File.read(doc_path, encoding: "UTF-8")
        lines = content.lines

        heading_idx = lines.index { |l| l.strip.match?(/^#+\s+#{Regexp.escape(section_heading)}\s*$/) }
        return "" unless heading_idx

        level = lines[heading_idx].match(/^(#+)/)[1].length

        body_lines = []
        lines[(heading_idx + 1)..].each do |line|
          if line.match?(/^(#+)\s/)
            line_level = line.match(/^(#+)/)[1].length
            break if line_level <= level
          end
          body_lines << line
        end

        body_lines.join.strip
      end
    end
  end
end
