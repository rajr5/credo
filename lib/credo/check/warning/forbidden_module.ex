defmodule Credo.Check.Warning.ForbiddenModule do
  use Credo.Check,
    base_priority: :high,
    category: :warning,
    param_defaults: [modules: []],
    explanations: [
      check: """
      Some modules that are included by a package may be hazardous
      if used by your application. Use this check to allow these modules in
      your dependencies but forbid them to be used in your application.

      Examples:

      The `:ecto_sql` package includes the `Ecto.Adapters.SQL` module,
      but direct usage of the `Ecto.Adapters.SQL.query/4` function, and related functions, may
      cause issues when using Ecto's dynamic repositories.
      """,
      params: [modules: "Modules that must not be used."]
    ]

  alias Credo.Code

  @impl Credo.Check
  def run(source_file = %SourceFile{}, params) do
    modules = Params.get(params, :modules, __MODULE__)

    Code.prewalk(source_file, &traverse(&1, &2, modules, IssueMeta.for(source_file, params)))
  end

  defp traverse(ast = {:__aliases__, meta, module}, issues, forbidden_modules, issue_meta) do
    if Enum.member?(forbidden_modules, Module.concat(module)) do
      {ast, [issue_for(issue_meta, meta[:line], module) | issues]}
    else
      {ast, issues}
    end
  end

  defp traverse(ast, issues, _, _), do: {ast, issues}

  defp issue_for(issue_meta, line_no, module) do
    trigger = module |> Module.concat() |> Code.Module.name()

    format_issue(
      issue_meta,
      message: "The `#{trigger}` module is not allowed.",
      trigger: trigger,
      line_no: line_no
    )
  end
end
