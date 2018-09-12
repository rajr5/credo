defmodule Credo.CLI.Task.LoadAndValidateSourceFiles do
  use Credo.Execution.Task

  alias Credo.CLI.Output
  alias Credo.Sources

  def call(exec, _opts \\ []) do
    {time_load, source_files} =
      :timer.tc(fn ->
        exec
        |> Sources.find()
        |> Enum.group_by(& &1.status)
      end)

    Output.complain_about_invalid_source_files(Map.get(source_files, :invalid, []))
    Output.complain_about_timed_out_source_files(Map.get(source_files, :timed_out, []))

    exec
    |> put_source_files(Map.get(source_files, :valid, []))
    |> put_assign("credo.time.source_files", time_load)
  end
end
