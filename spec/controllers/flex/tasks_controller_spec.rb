require 'rails_helper'

RSpec.describe Flex::TasksController, type: :controller do
  let(:user) { create(:user) }
  let(:case_record) { create(:test_case) }
  let(:application_form) { create(:application_form, case: case_record) }
  let(:task) { case_record.create_task(Flex::Task) }

  before do
    Rails.application.routes.draw do
      resources :tasks, only: [ :index, :show, :update ], controller: 'flex/tasks'
      resources :flex_tasks, only: [ :index, :show, :update ], controller: 'flex/tasks'
      resources :flex, only: [ :index, :show, :update ], controller: 'flex/tasks'
    end
    raise "Task ID is not set" unless task.id
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

      context 'when updating a task' do
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
