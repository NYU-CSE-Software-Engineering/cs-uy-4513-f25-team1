Quadratic
---------

Quadratic gives your team everything needed to plan, track, and ship -- without the bloat.

<details>
<summary>Quadratic?</summary>
This project was formerly known as Jira-lite/Lira
</details>

Features
--------

- Create and manage projects with descriptions and GitHub repository links. Control access through role-based permissions.
- Create tasks with title, description, type, priority levels, due dates, and branch links. Filter and sort tasks by multiple criteria.
- Structured workflow with To Do, In Progress, In Review, and Completed statuses. Developers request review, managers approve completion.
- Invite team members by email or username. Three roles: Manager, Developer, and Invited. Track individual contribution percentages.
- Add, edit, and delete comments on tasks. Markdown support for rich formatting.
- Upload images, PDFs, Word, and Excel files to tasks. Preview and manage media files directly in the task view.

Team Members
------------

[Wes Simpson](https://github.com/wessimpson)  
[Perry Huang](https://github.com/pearmeow)  
[Chaewon Song](https://github.com/Chaewon-Song)  
[Zesan Rahman](https://github.com/Zesan-Rahman)  
[Zicheng Teng](https://github.com/zichengteng)

Setup
-----

You must have Ruby 3.4.5 and Bundler installed  
Clone the repository, `cd` into it, and run the following commands.

```
bundle install
bundle exec rails db:reset
bundle exec rails db:migrate
bundle exec rails s
```
  
Then visit [localhost on port 3000](http://localhost:3000)

Testing
-------

To run cucumber and rspec tests, run these commands at the root of the repo.

```
bundle exec cucumber
bundle exec rspec
```
