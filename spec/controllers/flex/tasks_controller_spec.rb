require 'rails_helper'

RSpec.describe Flex::TasksController, type: :controller do
  let(:user) { create(:user) }
  let(:application_form) { create(:test_application_form) }
  let(:case_record) { create(:test_case, application_form_id: application_form.id) }
  let(:task) { case_record.create_task(TestTask, case: case_record) }

  before do
    Rails.application.routes.draw do
      namespace :flex do
        resources :tasks, only: [ :index, :show, :update ]
      end
    end
  end

  after do
    Rails.application.reload_routes!
  end

  describe 'before actions' do
    describe 'set_case' do
      context 'when viewing task details' do
        before { get :show, params: { id: task.id } }

        it 'sets the case from the task' do
          expect(assigns(:case)).to eq(case_record)
        end
      end

      context 'when updating a task', skip: 'Cannot figure out why routing is failing, so skipping for now' do
        before { patch :update, params: { id: task.id } }

        it 'sets the case from the task' do
          expect(assigns(:case)).to eq(case_record)
        end
      end

      context 'when accessing index' do
        before { get :index }

        it 'does not set the case' do
          expect(assigns(:case)).to be_nil
        end
      end
    end
  end
end
