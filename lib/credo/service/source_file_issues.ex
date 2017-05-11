defmodule Credo.Service.SourceFileIssues do
  use GenServer

  alias Credo.SourceFile
  alias Credo.Config

  def start_server(config) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])

    %Config{config | issues_pid: pid}
  end

  def append(%Config{issues_pid: pid}, %SourceFile{filename: filename}, issue) do
    GenServer.call(pid, {:append, filename, issue})
  end

  def get(%Config{issues_pid: pid}, %SourceFile{filename: filename}) do
    GenServer.call(pid, {:get, filename})
  end

  def to_map(%Config{issues_pid: pid}) do
    GenServer.call(pid, :to_map)
  end

  # callbacks

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:append, filename, issue}, _from, current_state) do
    issues = List.wrap(current_state[filename])
    new_issue_list = List.wrap(issue) ++ issues
    new_current_state = Map.put(current_state, filename, new_issue_list)

    {:reply, new_issue_list, new_current_state}
  end

  def handle_call({:get, filename}, _from, current_state) do
    {:reply, List.wrap(current_state[filename]), current_state}
  end

  def handle_call(:to_map, _from, current_state) do
    {:reply, current_state, current_state}
  end
end
