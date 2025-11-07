require 'rails_helper'

RSpec.describe Task, type: :model do 
  before do
    @project = Project.create!(name: "Alpha")
  end

  context "creating a task in project Alpha" do
    it "creates a task with valid inputs" do
      @task = Task.create!(title: "Implement WIP limit", status: "To Do", project_id: @project[:id])
      expect(@task).to be_valid
    end

    it "fails to create task with title" do
      @task = Task.new(title: "", status: "To Do", project_id: @project[:id])
      expect(@task).to_not be_valid
    end
  end
end
