require 'rails_helper'
require 'generators/flex/staff/staff_generator'
require 'fileutils'
require 'tmpdir'

RSpec.describe Flex::Generators::StaffGenerator, type: :generator do
  let(:destination_root) { Dir.mktmpdir }
  let(:generator) { described_class.new([], {}, destination_root: destination_root) }

  before do
    FileUtils.mkdir_p("#{destination_root}/app/controllers")
    FileUtils.mkdir_p("#{destination_root}/app/views/staff")
    FileUtils.mkdir_p("#{destination_root}/app/views/tasks")
    FileUtils.mkdir_p("#{destination_root}/spec/requests")
    FileUtils.mkdir_p("#{destination_root}/config")
    File.write("#{destination_root}/config/routes.rb", "Rails.application.routes.draw do\nend\n")
    allow(generator).to receive(:route)
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
      content = File.read(staff_controller_path)
      expect(content).to include("class StaffController < Flex::StaffController")
    end

    it "creates tasks controller" do
      tasks_controller_path = "#{destination_root}/app/controllers/tasks_controller.rb"
      expect(File.exist?(tasks_controller_path)).to be true
      content = File.read(tasks_controller_path)
      expect(content).to include("class TasksController < Flex::TasksController")
    end

    it "creates staff index view" do
      staff_view_path = "#{destination_root}/app/views/staff/index.html.erb"
      expect(File.exist?(staff_view_path)).to be true
      content = File.read(staff_view_path)
      expect(content).to include("Staff portal dashboard")
    end

    it "creates tasks index view" do
      tasks_index_path = "#{destination_root}/app/views/tasks/index.html.erb"
      expect(File.exist?(tasks_index_path)).to be true
      content = File.read(tasks_index_path)
      expect(content).to include("render template: 'flex/tasks/index'")
    end

    it "creates task show view" do
      task_show_path = "#{destination_root}/app/views/tasks/show.html.erb"
      expect(File.exist?(task_show_path)).to be true
      content = File.read(task_show_path)
      expect(content).to include("render template: 'flex/tasks/show'")
    end

    it "creates tasks spec" do
      tasks_spec_path = "#{destination_root}/spec/requests/tasks_spec.rb"
      expect(File.exist?(tasks_spec_path)).to be true
      content = File.read(tasks_spec_path)
      expect(content).to include('RSpec.describe "/staff/tasks"')
    end

    it "adds routes" do
      expect(generator).to have_received(:route).with(include('scope path: "/staff"'))
    end
  end
end
