class TestCase < Strata::Case
  # A simple test case to test the Case abstract class functionality
  # This class should not have any custom functionality added to it

  has_one :application_form, foreign_key: :id, primary_key: :application_form_id, class_name: "TestApplicationForm"
end
