module Flex
  class PassportApplicationBusinessProcessManager
    include Singleton

    attr_reader :business_process

    private

    def initialize
      @business_process = create_passport_application_business_process
    end

    def create_passport_application_business_process
      business_process = BusinessProcess.new
      business_process.name = 'Passport Application Process'
      business_process.description = 'Process for applying for a passport'
      business_process.define_steps(self.create_passport_application_business_process_steps)
      business_process.define_transitions(
        {
          "collect application info" => 'verify identity',
          "verify identity" => 'review passport photo',
          "review passport photo" => 'end'
        }
      )
      business_process.define_start('collect application info')
      business_process
    end

    def create_passport_application_business_process_steps
      {
        'collect application info' => SystemProcess.new(->(kase) { kase.mark_application_info_collected }), # simulate collecting application info
        'verify identity' => SystemProcess.new(->(kase) { kase.verify_identity }), # simulate verifying identity
        'review passport photo' => SystemProcess.new(->(kase) { kase.approve }), # simulate reviewing passport photo
        'end' => SystemProcess.new(->(kase) { kase.close }) # close case
      }
    end
  end
end
