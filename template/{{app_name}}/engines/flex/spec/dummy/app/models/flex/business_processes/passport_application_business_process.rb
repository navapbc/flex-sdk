module Flex
  class PassportApplicationBusinessProcess < BusinessProcess
    
    protected
    
    def get_steps
      {
        "step_1": CollectUserInformationUserTask.new,
        "step_2": TakePassportPhotoUserTask.new,
        "step_3": VerifyIdentitySystemProcess.new
      }
    end
  end
end
