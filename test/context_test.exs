defmodule ElixirScript.ContextTest do
  use ExUnit.Case, async: true
  import Mox

  alias ElixirScript.Context
  alias Test.Fixtures.GitHubWorkflowRun

  setup :verify_on_exit!

  describe "from_github_environment/0" do
    test "returns a Context struct with default values when environment variables are not set" do
      stub(SystemEnvBehaviourMock, :get_env, fn varname, default ->
        GitHubWorkflowRun.env()[varname] || default
      end)

      assert Context.from_github_environment() == %Context{
               action: "script",
               actor: "gaggle",
               api_url: "https://api.github.com",
               event_name: "push",
               graphql_url: "https://api.github.com/graphql",
               job: "event-context-is-available",
               payload: %{
                 after: "2ea150fa30b30dec0aeb85eb93469eda2d95c7d7",
                 compare:
                   "https://github.com/gaggle/elixir_script/compare/5ace270b6afc...2ea150fa30b3",
                 ref: "refs/heads/atom-context",
                 repository: %{
                   id: 675_841_662,
                   contents_url:
                     "https://api.github.com/repos/gaggle/elixir_script/contents/{+path}",
                   url: "https://github.com/gaggle/elixir_script",
                   allow_forking: true,
                   pulls_url: "https://api.github.com/repos/gaggle/elixir_script/pulls{/number}",
                   collaborators_url:
                     "https://api.github.com/repos/gaggle/elixir_script/collaborators{/collaborator}",
                   trees_url: "https://api.github.com/repos/gaggle/elixir_script/git/trees{/sha}",
                   branches_url:
                     "https://api.github.com/repos/gaggle/elixir_script/branches{/branch}",
                   deployments_url:
                     "https://api.github.com/repos/gaggle/elixir_script/deployments",
                   has_projects: false,
                   description: "Run simple Elixir scripts, easily",
                   size: 105,
                   subscription_url:
                     "https://api.github.com/repos/gaggle/elixir_script/subscription",
                   has_issues: true,
                   issue_comment_url:
                     "https://api.github.com/repos/gaggle/elixir_script/issues/comments{/number}",
                   ssh_url: "git@github.com:gaggle/elixir_script.git",
                   default_branch: "main",
                   assignees_url:
                     "https://api.github.com/repos/gaggle/elixir_script/assignees{/user}",
                   git_refs_url:
                     "https://api.github.com/repos/gaggle/elixir_script/git/refs{/sha}",
                   forks: 0,
                   open_issues: 0,
                   notifications_url:
                     "https://api.github.com/repos/gaggle/elixir_script/notifications{?since,all,participating}",
                   created_at: 1_691_443_361,
                   pushed_at: 1_700_430_826,
                   blobs_url: "https://api.github.com/repos/gaggle/elixir_script/git/blobs{/sha}",
                   stargazers: 0,
                   node_id: "R_kgDOKEiGfg",
                   has_wiki: false,
                   labels_url: "https://api.github.com/repos/gaggle/elixir_script/labels{/name}",
                   license: nil,
                   hooks_url: "https://api.github.com/repos/gaggle/elixir_script/hooks",
                   html_url: "https://github.com/gaggle/elixir_script",
                   contributors_url:
                     "https://api.github.com/repos/gaggle/elixir_script/contributors",
                   topics: [],
                   language: "Elixir",
                   milestones_url:
                     "https://api.github.com/repos/gaggle/elixir_script/milestones{/number}",
                   keys_url: "https://api.github.com/repos/gaggle/elixir_script/keys{/key_id}",
                   releases_url:
                     "https://api.github.com/repos/gaggle/elixir_script/releases{/id}",
                   disabled: false,
                   open_issues_count: 0,
                   commits_url: "https://api.github.com/repos/gaggle/elixir_script/commits{/sha}",
                   name: "elixir_script",
                   updated_at: "2023-11-18T16:35:54Z",
                   mirror_url: nil,
                   languages_url: "https://api.github.com/repos/gaggle/elixir_script/languages",
                   watchers: 0,
                   forks_count: 0,
                   has_pages: false,
                   issue_events_url:
                     "https://api.github.com/repos/gaggle/elixir_script/issues/events{/number}",
                   forks_url: "https://api.github.com/repos/gaggle/elixir_script/forks",
                   private: false,
                   merges_url: "https://api.github.com/repos/gaggle/elixir_script/merges",
                   git_url: "git://github.com/gaggle/elixir_script.git",
                   statuses_url:
                     "https://api.github.com/repos/gaggle/elixir_script/statuses/{sha}",
                   teams_url: "https://api.github.com/repos/gaggle/elixir_script/teams",
                   subscribers_url:
                     "https://api.github.com/repos/gaggle/elixir_script/subscribers",
                   full_name: "gaggle/elixir_script",
                   downloads_url: "https://api.github.com/repos/gaggle/elixir_script/downloads",
                   master_branch: "main",
                   events_url: "https://api.github.com/repos/gaggle/elixir_script/events",
                   fork: false,
                   compare_url:
                     "https://api.github.com/repos/gaggle/elixir_script/compare/{base}...{head}",
                   clone_url: "https://github.com/gaggle/elixir_script.git",
                   watchers_count: 0,
                   archived: false,
                   has_discussions: false,
                   svn_url: "https://github.com/gaggle/elixir_script",
                   has_downloads: true,
                   archive_url:
                     "https://api.github.com/repos/gaggle/elixir_script/{archive_format}{/ref}",
                   tags_url: "https://api.github.com/repos/gaggle/elixir_script/tags",
                   is_template: false,
                   issues_url:
                     "https://api.github.com/repos/gaggle/elixir_script/issues{/number}",
                   homepage: "https://github.com/marketplace/actions/elixir-script",
                   git_tags_url:
                     "https://api.github.com/repos/gaggle/elixir_script/git/tags{/sha}",
                   stargazers_url: "https://api.github.com/repos/gaggle/elixir_script/stargazers",
                   web_commit_signoff_required: false,
                   comments_url:
                     "https://api.github.com/repos/gaggle/elixir_script/comments{/number}",
                   stargazers_count: 0,
                   owner: %{
                     id: 2_316_447,
                     name: "gaggle",
                     type: "User",
                     url: "https://api.github.com/users/gaggle",
                     email: "mail@jonlauridsen.com",
                     events_url: "https://api.github.com/users/gaggle/events{/privacy}",
                     html_url: "https://github.com/gaggle",
                     node_id: "MDQ6VXNlcjIzMTY0NDc=",
                     avatar_url: "https://avatars.githubusercontent.com/u/2316447?v=4",
                     followers_url: "https://api.github.com/users/gaggle/followers",
                     following_url: "https://api.github.com/users/gaggle/following{/other_user}",
                     gists_url: "https://api.github.com/users/gaggle/gists{/gist_id}",
                     gravatar_id: "",
                     login: "gaggle",
                     organizations_url: "https://api.github.com/users/gaggle/orgs",
                     received_events_url: "https://api.github.com/users/gaggle/received_events",
                     repos_url: "https://api.github.com/users/gaggle/repos",
                     site_admin: false,
                     starred_url: "https://api.github.com/users/gaggle/starred{/owner}{/repo}",
                     subscriptions_url: "https://api.github.com/users/gaggle/subscriptions"
                   },
                   git_commits_url:
                     "https://api.github.com/repos/gaggle/elixir_script/git/commits{/sha}",
                   visibility: "public"
                 },
                 base_ref: nil,
                 before: "5ace270b6afc55dd3194d7e4cbf684ed753c2008",
                 commits: [
                   %{
                     id: "2ea150fa30b30dec0aeb85eb93469eda2d95c7d7",
                     message: "Output GITHUB_EVENT_PATH",
                     timestamp: "2023-11-19T22:53:38+01:00",
                     author: %{
                       name: "Jon Lauridsen",
                       email: "mail@jonlauridsen.com",
                       username: "gaggle"
                     },
                     url:
                       "https://github.com/gaggle/elixir_script/commit/2ea150fa30b30dec0aeb85eb93469eda2d95c7d7",
                     committer: %{
                       name: "Jon Lauridsen",
                       email: "mail@jonlauridsen.com",
                       username: "gaggle"
                     },
                     distinct: true,
                     tree_id: "e7fa0dcfd93820a600f21dd33e5e30f3eae6c150"
                   }
                 ],
                 created: false,
                 deleted: false,
                 forced: true,
                 head_commit: %{
                   id: "2ea150fa30b30dec0aeb85eb93469eda2d95c7d7",
                   message: "Output GITHUB_EVENT_PATH",
                   timestamp: "2023-11-19T22:53:38+01:00",
                   author: %{
                     name: "Jon Lauridsen",
                     email: "mail@jonlauridsen.com",
                     username: "gaggle"
                   },
                   url:
                     "https://github.com/gaggle/elixir_script/commit/2ea150fa30b30dec0aeb85eb93469eda2d95c7d7",
                   committer: %{
                     name: "Jon Lauridsen",
                     email: "mail@jonlauridsen.com",
                     username: "gaggle"
                   },
                   distinct: true,
                   tree_id: "e7fa0dcfd93820a600f21dd33e5e30f3eae6c150"
                 },
                 pusher: %{name: "gaggle", email: "mail@jonlauridsen.com"},
                 sender: %{
                   id: 2_316_447,
                   type: "User",
                   url: "https://api.github.com/users/gaggle",
                   events_url: "https://api.github.com/users/gaggle/events{/privacy}",
                   html_url: "https://github.com/gaggle",
                   node_id: "MDQ6VXNlcjIzMTY0NDc=",
                   avatar_url: "https://avatars.githubusercontent.com/u/2316447?v=4",
                   followers_url: "https://api.github.com/users/gaggle/followers",
                   following_url: "https://api.github.com/users/gaggle/following{/other_user}",
                   gists_url: "https://api.github.com/users/gaggle/gists{/gist_id}",
                   gravatar_id: "",
                   login: "gaggle",
                   organizations_url: "https://api.github.com/users/gaggle/orgs",
                   received_events_url: "https://api.github.com/users/gaggle/received_events",
                   repos_url: "https://api.github.com/users/gaggle/repos",
                   site_admin: false,
                   starred_url: "https://api.github.com/users/gaggle/starred{/owner}{/repo}",
                   subscriptions_url: "https://api.github.com/users/gaggle/subscriptions"
                 }
               },
               ref: "refs/heads/main",
               run_id: 6_922_972_178,
               run_number: 15,
               server_url: "https://github.com",
               sha: "77cefc59a7095f6b86508e8e26ff9f866da4b5e5",
               workflow: "Examples"
             }
    end
  end
end
