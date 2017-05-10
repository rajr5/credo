defmodule Credo.CLI.Command.Suggest do
  use Credo.CLI.Command

  @shortdoc "Suggest code objects to look at next (default)"

  alias Credo.Check.Runner
  alias Credo.Config
  alias Credo.CLI.Filter
  alias Credo.CLI.Output.IssuesGroupedByCategory
  alias Credo.CLI.Output.UI
  alias Credo.CLI.Output
  alias Credo.Sources

  @doc false
  def run(%Config{help: true}), do: print_help()
  def run(config) do
    config
    |> load_and_validate_source_files()
    |> Runner.prepare_config
    |> print_before_info()
    |> run_checks()
    |> print_results_and_summary()
    |> determine_success()
  end

  defp load_and_validate_source_files(config) do
    {time_load, {valid_source_files, invalid_source_files}} =
      :timer.tc fn ->
        config
        |> Sources.find
        |> Enum.partition(&(&1.valid?))
      end

    Output.complain_about_invalid_source_files(invalid_source_files)

    config
    |> Config.put_source_files(valid_source_files)
    |> Config.put_assign("credo.time.source_files", time_load)
  end

  defp print_before_info(config) do
    source_files = Config.get_source_files(config)

    out = output_mod(config)
    out.print_before_info(source_files, config)

    config
  end

  defp run_checks(%Config{} = config) do
    source_files = Config.get_source_files(config)

    {time_run, config} =
      :timer.tc fn ->
        Runner.run(source_files, config)
      end

    Config.put_assign(config, "credo.time.run_checks", time_run)
  end

  defp print_results_and_summary(%Config{} = config) do
    source_files = Config.get_source_files(config)

    time_load = Config.get_assign(config, "credo.time.source_files")
    time_run = Config.get_assign(config, "credo.time.run_checks")
    out = output_mod(config)

    out.print_after_info(source_files, config, time_load, time_run)

    config
  end

  defp determine_success(config) do
    source_files = Config.get_source_files(config)

    issues =
      config
      |> Config.get_issues
      |> Filter.important(config)
      |> Filter.valid_issues(config)

    case issues do
      [] ->
        :ok
      issues ->
        {:error, issues}
    end
  end

  defp output_mod(%Config{format: "oneline"}) do
    IssuesGroupedByCategory # TODO: offer short list (?)
  end
  defp output_mod(%Config{format: _}) do
    IssuesGroupedByCategory
  end

  defp print_help do
    usage = ["Usage: ", :olive, "mix credo suggest [paths] [options]"]
    description =
      """

      Suggests objects from every category that Credo thinks can be improved.
      """
    example = ["Example: ", :olive, :faint, "$ mix credo suggest lib/**/*.ex --all -c names"]
    options =
      """

      Arrows (↑ ↗ → ↘ ↓) hint at the importance of an issue.

      Suggest options:
        -a, --all             Show all issues
        -A, --all-priorities  Show all issues including low priority ones
        -c, --checks          Only include checks that match the given strings
        -C, --config-name     Use the given config instead of "default"
        -i, --ignore-checks   Ignore checks that match the given strings
            --format          Display the list in a specific format (oneline,flycheck)

      General options:
        -v, --version         Show version
        -h, --help            Show this help
      """

    UI.puts(usage)
    UI.puts(description)
    UI.puts(example)
    UI.puts(options)

    :ok
  end
end
