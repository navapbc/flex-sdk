module Flex
  class CollectUserInformationUserTask < UserTask
    def execute(kase)
      kase.passport_application_form.submitted?
    end
  end
end
