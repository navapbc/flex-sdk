# frozen_string_literal: true

require 'rails_helper'
require 'generators/strata/staff/staff_generator'
require 'fileutils'
require 'tmpdir'

RSpec.describe Strata::Generators::StaffGenerator, type: :generator do
  let(:destination_root) { Dir.mktmpdir }
  let(:generator) { described_class.new([], {}, destination_root: destination_root) }

  before do
    FileUtils.mkdir_p("#{destination_root}/app/controllers")
    FileUtils.mkdir_p("#{destination_root}/app/views/staff")
    FileUtils.mkdir_p("#{destination_root}/app/views/tasks")
    FileUtils.mkdir_p("#{destination_root}/spec/requests")
    FileUtils.mkdir_p("#{destination_root}/config")
    File.write("#{destination_root}/config/routes.rb", "Rails.application.routes.draw do\nend\n")
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  describe "file creation" do
    before do
      generator.invoke_all
    end

    it "creates staff controller" do
      staff_controller_path = "#{destination_root}/app/controllers/staff_controller.rb"
      expect(File.exist?(staff_controller_path)).to be true
    end

    it "creates tasks controller" do
      tasks_controller_path = "#{destination_root}/app/controllers/tasks_controller.rb"
      expect(File.exist?(tasks_controller_path)).to be true
    end

    it "creates staff index view" do
      staff_view_path = "#{destination_root}/app/views/staff/index.html.erb"
      expect(File.exist?(staff_view_path)).to be true
    end

    it "creates tasks index view" do
      tasks_index_path = "#{destination_root}/app/views/tasks/index.html.erb"
      expect(File.exist?(tasks_index_path)).to be true
    end

    it "creates task show view" do
      task_show_path = "#{destination_root}/app/views/tasks/show.html.erb"
      expect(File.exist?(task_show_path)).to be true
    end

    it "creates tasks spec" do
      tasks_spec_path = "#{destination_root}/spec/requests/tasks_spec.rb"
      expect(File.exist?(tasks_spec_path)).to be true
    end

    it "adds routes to routes.rb" do
      routes_content = File.read("#{destination_root}/config/routes.rb")
      expect(routes_content).to include('scope path: "/staff"')
      expect(routes_content).to include('get "staff", to: "staff#index"')
      expect(routes_content).to include('resources :tasks')
      expect(routes_content).to include('post :pick_up_next_task')
    end
  end
end
