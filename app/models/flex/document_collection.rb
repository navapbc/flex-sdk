module Flex
  # DocumentCollection is a value object that wraps ActiveStorage attachments
  # for use with the document flex attribute. It provides a clean interface
  # for working with multiple file attachments.
  #
  # @example Creating a document collection
  #   collection = Flex::DocumentCollection.new(model.documents_files)
  #   puts collection.count  # => 3
  #   collection.each { |file| puts file.filename }
  #
  class DocumentCollection
    include Enumerable

    def initialize(attachments = [])
      @attachments = attachments || []
    end

    # Returns the underlying ActiveStorage attachments
    def files
      @attachments
    end

    # Returns the number of attached files
    def count
      @attachments.count
    end

    # Returns true if no files are attached
    def empty?
      @attachments.empty?
    end

    # Returns true if files are attached
    def present?
      !empty?
    end

    # Enumerable support
    def each(&block)
      @attachments.each(&block)
    end

    # Returns an array of filenames
    def filenames
      @attachments.map(&:filename)
    end

    # Returns total size of all files in bytes
    def total_size
      @attachments.sum(&:byte_size)
    end
  end
end
