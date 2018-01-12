defmodule Mix.Tasks.Gandalf.Gen.Migration do
  @shortdoc "Generates Gandalf.DB's migration"

  @moduledoc """
  Generates the required Gandalf's database migration
  """
  use Mix.Task

  import Mix.Ecto
  import Mix.Generator

  @doc false
  def run(args) do
    no_umbrella!("ecto.gen.migration")

    repos = parse_repo(args)

    Enum.each(repos, fn repo ->
      ensure_repo(repo, args)
      path = migrations_path(repo)

      create_directory(path)

      Enum.each(
        [
          "create_user",
          "create_token",
          "create_client",
          "create_app"
        ],
        &generage_migration(&1, path)
      )
    end)
  end

  defp generage_migration(file, path) do
    source_path =
      :gandalf
      |> Application.app_dir()
      |> Path.join("priv/templates/#{file}.exs.eex")

    generated_file = EEx.eval_file(source_path, module_prefix: app_module())
    target_file = Path.join(path, "#{timestamp()}_gandalf_#{file}.exs")
    create_file(target_file, generated_file)
  end

  defp app_module do
    Mix.Project.config()
    |> Keyword.fetch!(:app)
    |> to_string()
    |> Macro.camelize()
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    {_megasec, _sec, microsec} = :os.timestamp
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}#{microsec}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)
end
