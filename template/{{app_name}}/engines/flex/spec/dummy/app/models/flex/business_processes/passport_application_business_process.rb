require_relative '../steps/user_tasks/collect_user_information_user_task'
require_relative '../steps/user_tasks/take_passport_photo_user_task'
require_relative '../steps/system_processes/verify_identity_system_process'
module Flex
  class PassportApplicationBusinessProcess < BusinessProcess
    # belongs_to :case, class_name: 'Flex::Case', foreign_key: 'case_id'
    
    protected
    
    def get_steps
      {
        "collect_user_info" => CollectUserInformationUserTask.new,
        "take_passport_photo" => PassportPhotoUserTask.new,
        "verify_system_identity" => VerifyIdentitySystemProcess.new
      }
    end
  end
end
