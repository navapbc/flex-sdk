# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Flows::TaskSectionComponent, type: :component do
  let(:page) { Strata::Flows::QuestionPage.new("first_name") }

  describe "#task_action" do
    context "when task dependencies are not met" do
      let(:task) { Strata::Flows::Task.new(:review, depends_on: :all, pages: [ page ]) }
      let(:flow) do
        fake_record = Struct.new(:class).new(Struct.new(:name).new("TestModel"))
        flow_task = task

        flow_obj = Object.new
        flow_obj.define_singleton_method(:record) { fake_record }
        flow_obj.define_singleton_method(:task_counter) { |_| 0 }
        flow_obj.define_singleton_method(:tasks) { [ flow_task ] }
        flow_obj.define_singleton_method(:dependencies_met?) { |_, **| false }
        flow_obj
      end

      it "renders a greyed-out 'Cannot start yet' label with no link" do
        component = described_class.new(flow: flow, task: task)
        rendered = render_inline(component)

        expect(rendered.text).to include("Cannot start yet")
        expect(rendered.css("a")).to be_empty
      end
    end
  end
end
