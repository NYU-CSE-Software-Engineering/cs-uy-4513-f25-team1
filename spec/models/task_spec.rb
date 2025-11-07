require 'rails_helper'

RSpec.describe Task, type: :model do 
  before do
    @project = Project.create!(name: "Alpha")
  end

  context "creating a task in project Alpha" do
    it "creates a task with valid inputs" do
      @task = Task.create!(title: "Implement WIP limit", status: "To Do")
      expect(task).to_be valid
    end
  end
end
