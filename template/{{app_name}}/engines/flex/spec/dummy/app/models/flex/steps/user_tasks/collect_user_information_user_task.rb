module Flex
  class CollectUserInformationUserTask < UserTask
    def execute(kase)
      kase.passport_application_form.has_all_necessary_fields?
    end
  end
end
