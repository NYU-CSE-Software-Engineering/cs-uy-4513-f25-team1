require 'rails_helper'

RSpec.describe "/tasks/new.html.erb", type: :view do
  before do
    Project.create!(name: "Test project") unless Project.find_by(id: 1)
  end

  it "displays the page" do
    assign(:projects, Project.find_by(id: 1))
    assign(:task, Task)

    render

    expect(rendered).to match(/New task/)
  end
end
