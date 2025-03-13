require 'test_helper'
require 'minitest/mock'

module Flex
  class ApplicationFormServiceTest < ActiveSupport::TestCase
    def setup
      @repository = Minitest::Mock.new
      @service = ApplicationFormService.new(repository: @repository)
    end

    [nil, false, ''].each do |id|
      test "update_form raises an error if the given id is falsy (#{id.inspect})" do
        assert_raises(ArgumentError) { @service.update_form(id, {}) }
      end
    end

    [nil, {}, false].each do |params|
      test "update_form raises an error if params are not provided (#{params.inspect})" do
        assert_raises(ArgumentError) { @service.update_form(1, params) }
      end
    end

    test "update_form raises an error if the application form is already submitted" do
      params = { status: ApplicationForm.statuses[:submitted] }
      id = rand(1..1000)
      
      @repository.expect(:find_fields, ApplicationForm.statuses[:submitted], [id, ['status']])
      
      assert_raises(RuntimeError) { @service.update_form(id, params) }
      
      @repository.verify
    end

    test "update_form updates the application form with the given parameters if id and params are valid" do
      params = { status: ApplicationForm.statuses[:in_progress] }
      id = rand(1..1000)
      
      @repository.expect(:find_fields, ApplicationForm.statuses[:in_progress], [id, ['status']])
      @repository.expect(:update, true, [id, params])
      
      @service.update_form(id, params)
      
      assert @repository.verify
    end

    [nil, false, ''].each do |id|
      test "submit_form raises an error if the given id is falsy (#{id.inspect})" do
        assert_raises(ArgumentError) { @service.submit_form(id) }
      end
    end

    [
      { status: ApplicationForm.statuses[:in_progress] },
      {},
      { status: ApplicationForm.statuses[:submitted] },
      { status: nil }
    ].each do |params|
      test "submit_form always updates status to submitted regardless of the given params (#{params.inspect})" do
        id = rand(1..1000)
        
        @repository.expect(:find_fields, ApplicationForm.statuses[:in_progress], [id, ['status']])
        @repository.expect(:update, true, [id, { status: ApplicationForm.statuses[:submitted] }])
        
        @service.submit_form(id, params: params)
        
        assert @repository.verify
      end
    end
  end
end
