{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start()
ExUnit.configure(exclude: :integration)

Ecto.Adapters.SQL.Sandbox.mode(Platform.Repo, :manual)

Platform.VideoConverter.TestAdapter.start_link

# deactivate "warning: redefining module"
#Code.compiler_options(ignore_module_conflict: true)
Mox.defmock(Platform.SlidesAPIMock, for: Platform.SlideAPI)