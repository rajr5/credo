defmodule Credo.Code.InterpolationHelper do
  @moduledoc false

  alias Credo.Code.Token

  @doc false
  def replace_interpolations(source, char \\ " ") do
    positions = interpolation_positions(source)
    lines = String.split(source, "\n")

    positions
    |> Enum.reduce(lines, &replace_line(&1, &2, char))
    |> Enum.join("\n")
  end

  defp replace_line({line_no, col_start, col_end}, lines, char) do
    List.update_at(lines, line_no - 1, &replace_line(&1, col_start, col_end, char))
  end

  defp replace_line(line, col_start, col_end, char) do
    String.slice(line, 0, col_start - 1) <>
      String.duplicate(char, col_end - col_start) <>
      String.slice(line, col_end - 1, String.length(line) - 1)
  end

  @doc false
  def interpolation_positions(source) do
    source
    |> Credo.Code.to_tokens()
    |> Enum.flat_map(&map_interpolations(&1, source))
    |> Enum.reject(&is_nil/1)
  end

  # Elixir >= 1.6.0
  defp map_interpolations(
         {:sigil, {_line_no, _col_start, nil}, _, list, _, _sigil_start_char},
         source
       ) do
    interpolation_positions_for_quoted_string(list, source)
  end

  defp map_interpolations({:bin_string, {_line_no, _col_start, _}, list}, source) do
    interpolation_positions_for_quoted_string(list, source)
  end

  defp map_interpolations({:bin_heredoc, {line_no, _col_start, _}, list}, source) do
    first_line_in_heredoc = get_line(source, line_no + 1)
    padding_in_first_line =
      determine_padding_at_start_of_line(first_line_in_heredoc)

    interpolation_positions_for_quoted_string(list, source)
    |> Enum.reject(&is_nil/1)
    |> add_to_col_start_and_end(padding_in_first_line)
  end

  defp map_interpolations({:atom_unsafe, {_line_no, _col_start, _}, list}, source) do
    interpolation_positions_for_quoted_string(list, source)
  end

  defp map_interpolations(_, _source), do: []

  defp interpolation_positions_for_quoted_string(list, source)
       when is_list(list) do
    find_interpolations(list, source)
  end

  defp find_interpolations(value, source) when is_list(value) do
    Enum.map(value, &find_interpolations(&1, source))
  end

  # {{1, 25, 32}, [{:identifier, {1, 27, 31}, :name}]}
  defp find_interpolations({{_line_no, _col_start2, _}, _list} = token, source) do
    {line_no, col_start, col_end} = Token.position(token)

    line = get_line(source, line_no)
    rest_of_line = String.slice(line, col_end, String.length(line) - col_end)
    padding = determine_padding_at_start_of_line(rest_of_line)

    {line_no, col_start, col_end + padding}
  end

  defp find_interpolations(_value, _source), do: nil

  defp determine_padding_at_start_of_line(line) do
    ~r/^\s+/
    |> Regex.run(line)
    |> List.wrap
    |> Enum.join()
    |> String.length()
  end

  defp add_to_col_start_and_end(positions, padding) do
    Enum.map(positions, fn {line_no, col_start, col_end} ->
      {line_no, col_start + padding, col_end + padding}
    end)
  end

  defp get_line(source, line_no) do
    source
    |> String.split("\n")
    |> Enum.at(line_no - 1)
  end
end
