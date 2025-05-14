class TestCase < Flex::Case
  # A simple test case to test the Case abstract class functionality
  # This class should not have any custom functionality added to it
  def business_process
    TestBusinessProcessManager.instance.business_process
  end
end
