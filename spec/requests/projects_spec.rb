require 'rails_helper'
# Just adding a comment so that the new tests get pushed to the repo :)
RSpec.describe "Projects", type: :request do
  let!(:user) { User.create!(email_address: 'test@example.com', username: 'tester', password: 'SecurePassword123') }
  let!(:other_user) { User.create!(email_address: 'other@example.com', username: 'otheruser', password: 'SecurePassword123') }

  def sign_in(user)
    post "/session", params: { email_address: user.email_address, password: 'SecurePassword123' }
  end

  describe "GET /projects/new" do
    before { sign_in(user) }

    it "responds with 200 and renders the new project form" do
      get new_project_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /projects" do
    before { sign_in(user) }

    context "validation tests" do
      it "cannot create project without name" do
        expect {
          post projects_path, params: { project: { name: "", description: "A description" } }
        }.not_to change(Project, :count)

        expect(response).to redirect_to(new_project_path)
        expect(flash[:name_error]).to eq("Name can't be blank")
      end

      it "cannot create project without description" do
        expect {
          post projects_path, params: { project: { name: "My Project", description: "" } }
        }.not_to change(Project, :count)

        expect(response).to redirect_to(new_project_path)
        expect(flash[:description_error]).to eq("Description can't be blank")
      end

      it "cannot create project with both name and description missing" do
        expect {
          post projects_path, params: { project: { name: "", description: "" } }
        }.not_to change(Project, :count)

        expect(response).to redirect_to(new_project_path)
      end
    end

    context "invite validation tests" do
      it "shows error when inviting non-existent user by email" do
        expect {
          post projects_path, params: {
            project: {
              name: "Test Project",
              description: "Test description",
              invites: [ "nonexistent@example.com" ]
            }
          }
        }.not_to change(Project, :count)

        expect(response).to redirect_to(new_project_path)
        expect(flash[:invite_error]).to include("nonexistent@example.com")
      end

      it "shows error when inviting non-existent user by username" do
        expect {
          post projects_path, params: {
            project: {
              name: "Test Project",
              description: "Test description",
              invites: [ "nonexistent_user" ]
            }
          }
        }.not_to change(Project, :count)

        expect(response).to redirect_to(new_project_path)
        expect(flash[:invite_error]).to include("nonexistent_user")
      end

      it "successfully invites user by email" do
        expect {
          post projects_path, params: {
            project: {
              name: "Test Project",
              description: "Test description",
              invites: [ other_user.email_address ]
            }
          }
        }.to change(Project, :count).by(1)
          .and change(Collaborator, :count).by(2)

        project = Project.last
        expect(response).to redirect_to(project_path(project))

        invited_collab = Collaborator.find_by(user: other_user, project: project)
        expect(invited_collab).to be_present
        expect(invited_collab.role).to eq("invited")
      end

      it "successfully invites user by username" do
        expect {
          post projects_path, params: {
            project: {
              name: "Test Project",
              description: "Test description",
              invites: [ other_user.username ]
            }
          }
        }.to change(Project, :count).by(1)
          .and change(Collaborator, :count).by(2)

        project = Project.last
        invited_collab = Collaborator.find_by(user: other_user, project: project)
        expect(invited_collab).to be_present
        expect(invited_collab.role).to eq("invited")
      end
    end

    context "successful creation tests" do
      it "can create project with only name and description" do
        expect {
          post projects_path, params: {
            project: {
              name: "My Project",
              description: "My project description"
            }
          }
        }.to change(Project, :count).by(1)
          .and change(Collaborator, :count).by(1)

        project = Project.last
        expect(response).to redirect_to(project_path(project))
        expect(flash[:created]).to eq("Project was successfully created.")
        expect(project.name).to eq("My Project")
        expect(project.description).to eq("My project description")
        expect(project.repo).to be_nil
      end

      it "can create project with name, description, and GitHub repo link" do
        expect {
          post projects_path, params: {
            project: {
              name: "My Project",
              description: "My project description",
              repo: "https://github.com/user/repo"
            }
          }
        }.to change(Project, :count).by(1)

        project = Project.last
        expect(project.repo).to eq("https://github.com/user/repo")
      end

      it "can create project with name, description, and invites" do
        expect {
          post projects_path, params: {
            project: {
              name: "My Project",
              description: "My project description",
              invites: [ other_user.email_address ]
            }
          }
        }.to change(Project, :count).by(1)
          .and change(Collaborator, :count).by(2)
      end

      it "can create project with all fields" do
        expect {
          post projects_path, params: {
            project: {
              name: "Full Project",
              description: "Full description",
              repo: "https://github.com/user/repo",
              invites: [ other_user.email_address ]
            }
          }
        }.to change(Project, :count).by(1)
          .and change(Collaborator, :count).by(2)

        project = Project.last
        expect(project.name).to eq("Full Project")
        expect(project.description).to eq("Full description")
        expect(project.repo).to eq("https://github.com/user/repo")
      end

      it "creator becomes manager collaborator on successful creation" do
        post projects_path, params: {
          project: {
            name: "My Project",
            description: "My project description"
          }
        }

        project = Project.last
        manager_collab = Collaborator.find_by(user: user, project: project)
        expect(manager_collab).to be_present
        expect(manager_collab.role).to eq("manager")
      end

      it "invited users get collaborator records with invited role" do
        post projects_path, params: {
          project: {
            name: "My Project",
            description: "My project description",
            invites: [ other_user.email_address ]
          }
        }

        project = Project.last
        invited_collab = Collaborator.find_by(user: other_user, project: project)
        expect(invited_collab).to be_present
        expect(invited_collab.role).to eq("invited")
      end
    end

    context "edge cases" do
      it "cannot invite yourself to your own project" do
        expect {
          post projects_path, params: {
            project: {
              name: "My Project",
              description: "My project description",
              invites: [ user.email_address ]
            }
          }
        }.not_to change(Project, :count)

        expect(response).to redirect_to(new_project_path)
        expect(flash[:invite_error]).to be_present
      end

      it "duplicate project name for same manager shows error" do
        Project.create!(name: "Existing Project", description: "Existing description")
        Collaborator.create!(user: user, project: Project.last, role: :manager)

        expect {
          post projects_path, params: {
            project: {
              name: "Existing Project",
              description: "New description"
            }
          }
        }.not_to change(Project, :count)

        expect(response).to redirect_to(new_project_path)
        expect(flash[:name_duplicate_error]).to eq("Name has already been taken")
      end

      it "allows same project name for different managers" do
        other_manager = User.create!(email_address: 'manager@example.com', username: 'manager', password: 'SecurePassword123')
        other_project = Project.create!(name: "Same Name", description: "Other description")
        Collaborator.create!(user: other_manager, project: other_project, role: :manager)

        expect {
          post projects_path, params: {
            project: {
              name: "Same Name",
              description: "My description"
            }
          }
        }.to change(Project, :count).by(1)

        expect(response).to redirect_to(project_path(Project.last))
      end
    end
  end

  describe "GET /projects/:id" do
    let!(:project) { Project.create!(name: "Test Project", description: "Test description") }

    before do
      Collaborator.create!(user: user, project: project, role: :manager)
      sign_in(user)
    end

    it "responds with 200 and shows the project" do
      get project_path(project)
      expect(response).to have_http_status(:ok)
    end

    it "displays project description" do
      get project_path(project)
      expect(response.body).to include(project.description)
    end

    it "displays project repo link when present" do
      project.update!(repo: "https://github.com/user/repo")
      get project_path(project)
      expect(response.body).to include("https://github.com/user/repo")
    end
  end
end
