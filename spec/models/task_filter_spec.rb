require 'rails_helper'

RSpec.describe "Task filtering", type: :model do
  let(:project1) do
    Project.create!(
      name: 'Project One',
      description: 'For filter specs 1'
    )
  end

  let(:project2) do
    Project.create!(
      name: 'Project Two',
      description: 'For filter specs 2'
    )
  end

  let(:user) do
    User.create!(
      username: 'filter_user',
      email_address: 'filter@example.com',
      password_digest: BCrypt::Password.create('password123')
    )
  end

  before do
    Task.create!(
      title: 'P1 Not started',
      status: 'not started',
      project: project1,
      user: user
    )

    Task.create!(
      title: 'P1 In progress',
      status: 'in progress',
      project: project1,
      user: user
    )

    Task.create!(
      title: 'P1 Done',
      status: 'done',
      project: project1,
      user: user
    )

    Task.create!(
      title: 'P2 In progress',
      status: 'in progress',
      project: project2,
      user: user
    )
  end

  it 'can filter tasks by project' do
    p1_tasks = Task.where(project: project1)
    p2_tasks = Task.where(project: project2)

    expect(p1_tasks.pluck(:title)).to include('P1 Not started', 'P1 In progress', 'P1 Done')
    expect(p1_tasks.pluck(:title)).not_to include('P2 In progress')

    expect(p2_tasks.pluck(:title)).to contain_exactly('P2 In progress')
  end

  it 'can filter tasks by status' do
    in_progress_tasks = Task.where(status: 'in progress')

    titles = in_progress_tasks.pluck(:title)
    expect(titles).to include('P1 In progress', 'P2 In progress')
    expect(titles).not_to include('P1 Not started', 'P1 Done')
  end
end
