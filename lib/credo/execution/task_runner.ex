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

  group :validate_config do
    task Credo.Execution.Task.ValidateConfig
  end

  group :resolve_config do
    task Credo.Execution.Task.ResolveConfig
# TODO: refactor
#    task UseColors
#    task CheckForUpdates
#    task RequireRequires
  end

# TODO: implement
#  group :validate_command do
#    task PutCommandIntoToken
#  end

  group :run_command do
    task Credo.Execution.Task.RunCommand
  end

# TODO: implement
#  group :convert_results do
#    task ConvertResults
#  end

# TODO: implement
#  group :present_results do
#    task PrintResults
#  end

  group :halt_execution do
# TODO: refactor
#    task PutExitStatusForIssues
#    task HaltIfExitStatus
    task Credo.Execution.Task.HaltExecution
  end
end
