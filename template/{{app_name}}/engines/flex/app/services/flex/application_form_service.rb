module Flex
  class ApplicationFormService
    def initialize(repository: ApplicationFormRepository.new)
      @repository = repository
    end

    def create_form(params)
      @repository.create(params)
    end

    def update_form(id, params)
      raise ArgumentError, "Invalid id (#{id.inspect})" unless id.present?
      raise ArgumentError, "Invalid params (#{params.inspect})" unless params.present?

      if is_status_submitted?(id)
        raise "Application form for id #{id} is already submitted and can no longer be modified"
      else
        @repository.update(id, params)
      end
    end

    def submit_form(id, params: {})
      update_form(id, params.merge(status: ApplicationForm.statuses[:submitted]))
    end

    private

    def is_status_submitted?(id)
      status = @repository.find_fields(id, [ "status" ])
      status == ApplicationForm.statuses[:submitted]
    end
  end
end
