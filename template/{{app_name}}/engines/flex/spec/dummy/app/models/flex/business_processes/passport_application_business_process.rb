module Flex
  class PassportApplicationBusinessProcess < BusinessProcess
    # Add your custom business process logic here
    
    protected
    
    def get_steps
      {
        "step_1": Step1.new,
        "step_2": Step2.new
      }
    end
  end
end
