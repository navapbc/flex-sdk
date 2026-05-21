# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::Flows::Loop do
  before do
    child_class = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :business_name, :string
      attribute :role, :string
      validates :business_name, presence: true, on: :business_name
      validates :role, presence: true, on: :role
    end

    parent_class = Class.new do
      include ActiveModel::Model
      attr_accessor :prior_employers

      def initialize(prior_employers: [])
        @prior_employers = prior_employers
      end
    end

    stub_const("PriorEmployer", child_class)
    stub_const("EmploymentForm", parent_class)
  end

  let(:business_name_page) { Strata::Flows::QuestionPage.new(:business_name) }
  let(:role_page) { Strata::Flows::QuestionPage.new(:role) }

  describe "#initialize" do
    it "stores name, association, and pages" do
      loop_node = described_class.new(:prior_employer, association: :prior_employers)

      expect(loop_node.name).to eq(:prior_employer)
      expect(loop_node.association).to eq(:prior_employers)
      expect(loop_node.pages).to eq([])
    end

    it "defaults association to the loop name when not provided" do
      loop_node = described_class.new(:prior_employers)

      expect(loop_node.name).to eq(:prior_employers)
      expect(loop_node.association).to eq(:prior_employers)
    end
  end

  describe "#records_for" do
    it "returns the association on the flow record" do
      child_a = PriorEmployer.new(business_name: "Acme")
      child_b = PriorEmployer.new(business_name: "Globex")
      flow_record = EmploymentForm.new(prior_employers: [ child_a, child_b ])

      loop_node = described_class.new(:prior_employer, association: :prior_employers)

      expect(loop_node.records_for(flow_record)).to eq([ child_a, child_b ])
    end
  end

  describe "#completed?" do
    let(:loop_node) do
      described_class.new(:prior_employer, association: :prior_employers, pages: [ business_name_page, role_page ])
    end

    it "is true when every child record is valid on every loop page" do
      flow_record = EmploymentForm.new(prior_employers: [
        PriorEmployer.new(business_name: "Acme", role: "Engineer"),
        PriorEmployer.new(business_name: "Globex", role: "Manager")
      ])

      expect(loop_node).to be_completed(flow_record)
    end

    it "is false when any child record is invalid on any loop page" do
      flow_record = EmploymentForm.new(prior_employers: [
        PriorEmployer.new(business_name: "Acme", role: "Engineer"),
        PriorEmployer.new(business_name: "Globex", role: nil)
      ])

      expect(loop_node).not_to be_completed(flow_record)
    end

    it "is true (vacuously) when the relation is empty" do
      flow_record = EmploymentForm.new(prior_employers: [])

      expect(loop_node).to be_completed(flow_record)
    end
  end

  describe "#started?" do
    let(:loop_node) do
      described_class.new(:prior_employer, association: :prior_employers, pages: [ business_name_page, role_page ])
    end

    it "is true when any child record has any completed page" do
      flow_record = EmploymentForm.new(prior_employers: [
        PriorEmployer.new(business_name: "Acme")
      ])

      expect(loop_node).to be_started(flow_record)
    end

    it "is false when no child records exist" do
      flow_record = EmploymentForm.new(prior_employers: [])

      expect(loop_node).not_to be_started(flow_record)
    end

    it "is false when no child records have any completed page" do
      flow_record = EmploymentForm.new(prior_employers: [
        PriorEmployer.new
      ])

      expect(loop_node).not_to be_started(flow_record)
    end
  end
end
