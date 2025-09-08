require 'rails_helper'

RSpec.describe Flex::ApplicationFormPolicy, type: :policy do
  # Create a test policy class that includes the module
  let(:test_policy_class) do
    Class.new(::ApplicationPolicy) do
      include Flex::ApplicationFormPolicy
      
      attr_reader :user, :record
      
      def initialize(user, record)
        @user = user
        @record = record
      end
    end
  end
  
  subject { test_policy_class.new(current_user, record) }

  let(:owning_user) { create(:user) }
  let(:base_record) { create(:test_application_form, user_id: owning_user.id) }

  let(:record) { base_record }

  let(:resolved_scope) do
    described_class::Scope.new(current_user, TestApplicationForm.all).resolve
  end

  context "when unauthenticated" do
    let(:current_user) { nil }

    it { is_expected_in_block.to raise_error(Pundit::NotAuthorizedError) }
  end

  context "when owning user" do
    let(:current_user) { owning_user }

    it { is_expected.to permit_all_actions }

    it 'includes all records in the resolved scope' do
      expect(resolved_scope).to include(record)
    end
  end

  context "when owning user, on submitted form" do
    let(:current_user) { owning_user }
    let(:record) do
      base_record.submit_application
      base_record
    end

    it { is_expected.to forbid_only_actions(:destroy, :review, :edit, :update, :submit) }

    it 'includes all records in the resolved scope' do
      expect(resolved_scope).to include(record)
    end
  end

  context "when not owning user" do
    let(:current_user) { build(:user) }

    it { is_expected.to permit_only_actions(:create, :index, :new) }

    it 'includes nothing in the resolved scope' do
      expect(resolved_scope).to be_empty
    end
  end
end
