require 'rails_helper'

RSpec.describe Task, type: :model do 
  before do
    @project = Project.create!(name: "Alpha")

    visit project_tasks_path(@project)
  end

  context "when creating a task with valid inputs" do
    it "creates the task successfully" do
      click_link "New Task"

      fill_in "Title", with: "Implement WIP limit"

      select "To Do", from: "Status"

      click_button "Create Task"

      expect(page).to have_content("Implement WIP limit")

      within(".task-list") do
        expect(page).to have_content("Implement WIP limit")
      end
    end
  end
end
