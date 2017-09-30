defmodule Credo.Execution.TaskRunner do
  use Credo.Execution.TaskRunnerBuilder

  group :parse_cli_options do
    task Credo.Execution.Task.ParseOptions
  end

  group :validate_cli_options do
    task Credo.Execution.Task.ValidateOptions
  end

  group :convert_cli_options_to_config do
    task Credo.Execution.Task.ConvertCLIOptionsToConfig
  end

  group :determine_command do
    task Credo.Execution.Task.DetermineCommand
  end

  group :set_default_command do
    task Credo.Execution.Task.SetDefaultCommand
  end

  group :validate_config do
    task Credo.Execution.Task.ValidateConfig
  end

  group :resolve_config do
    task Credo.Execution.Task.UseColors
    task Credo.Execution.Task.RequireRequires
  end

  group :run_command do
    task Credo.Execution.Task.RunCommand
  end

  group :halt_execution do
    task Credo.Execution.Task.AssignExitStatusForIssues
    task Credo.Execution.Task.HaltIfExitStatusAssigned
  end
end
