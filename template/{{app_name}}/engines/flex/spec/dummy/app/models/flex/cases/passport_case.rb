module Flex
  class PassportCase < Case
    belongs_to :passport_application_form, class_name: 'Flex::PassportApplicationForm'
    has_many :business_processes, class_name: 'Flex::PassportApplicationBusinessProcess', foreign_key: :case_id, dependent: :destroy
    after_create :create_passport_application_business_process

    private

    def create_passport_application_business_process
      business_processes << PassportApplicationBusinessProcess.create({:case => self, :name => 'Passport Application Process'})
    end
  end
end
