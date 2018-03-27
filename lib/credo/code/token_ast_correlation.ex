defmodule Credo.Code.TokenAstCorrelation do
  #
  #
  #
  alias Credo.Code.Token

  def ast(source) do
    {:ok, ast} = Credo.Code.ast(source)

    tokens =
      Credo.Code.to_tokens(source)
      |> Enum.group_by(fn token ->
        {line_no, _, _, _} = Token.position(token)

        line_no
      end)

    lines = Credo.Code.to_lines(source) |> Enum.into(%{})

    {ast, _acc} = Macro.postwalk(ast, {[], 0}, &traverse_post(&1, &2, tokens, lines))
    ast
  end

  defp traverse_post({_, meta, _} = ast, {acc, counter}, token_map, source_map) do
    counter |> IO.inspect(label: "counter")
    ast |> IO.inspect(label: "ast")

    tokens = token_map[meta[:line]]

    IO.inspect(tokens, label: "tokens")

    line = source_map[meta[:line]]

    IO.inspect(line, label: "line")

    string = Macro.to_string(ast)

    string_matches =
      Regex.run(~r/\b#{string}\b/, line, return: :index)
      |> IO.inspect()

    column = nil

    column =
      case string_matches do
        [{col, _}] ->
          col + 1

        _ ->
          column
      end

    ast2 = Macro.update_meta(ast, &(&1 ++ [__column__: column]))

    IO.puts("")

    {ast2, {acc, counter + 1}}
  end

  defp traverse_post(ast, {acc, counter}, _tokens, _source_map) do
    # ast |> IO.inspect()

    # IO.puts("")

    {ast, {acc, counter + 1}}
  end

  #
  #
  #

  def find_tokens_in_ast(wanted_token, tokens, ast) do
    {prev, current, next} = find_current_prev_next_token(tokens, wanted_token)
    position = Credo.Code.Token.position(current)

    {line_no_start, _col_start, line_no_end, _col_end} = position

    line_ast =
      Credo.Code.prewalk(ast, &traverse_ast(&1, &2, line_no_start, line_no_end))
      |> IO.inspect(label: "prewalk")

    Credo.Code.postwalk(line_ast, &traverse_line(&1, &2))
    |> IO.inspect(label: "postwalk")
  end

  defp traverse_ast({_, meta, _} = ast, acc, line_no_start, line_no_end) do
    if meta[:line] >= line_no_start and meta[:line] <= line_no_end do
      {nil, acc ++ [ast]}
    else
      {ast, acc}
    end
  end

  defp traverse_ast(ast, acc, _line_no_start, _line_no_end) do
    {ast, acc}
  end

  #

  defp traverse_line(ast, acc) do
    {ast, acc}
  end

  defp find_current_prev_next_token(tokens, token) do
    [result] = traverse_prev_current_next(tokens, &matching_location(token, &1, &2, &3, &4), [])

    result
  end

  defp traverse_prev_current_next(tokens, callback, acc) do
    tokens
    |> case do
      [prev | [current | [next | rest]]] ->
        acc = callback.(prev, current, next, acc)

        traverse_prev_current_next([current | [next | rest]], callback, acc)

      _ ->
        acc
    end
  end

  defp matching_location(current, prev, current, next, acc) do
    acc ++ [{prev, current, next}]
  end

  defp matching_location(_, _prev, _current, _next, acc) do
    acc
  end
end
