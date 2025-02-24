# require 'app/models/application_form'


module FlexSdk
  class ApplicationFormManagement
    def self.save_things(obj)
      # Create a new instance of ApplicationForm and pass the data
      application_form = FlexSdk::ApplicationForm.new(obj)

      application_form.save_in_progress

      # Return the instance for inspection
      application_form
    end
  end
end
