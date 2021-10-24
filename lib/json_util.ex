defmodule JsonUtil do
  @moduledoc """
  Documentation for `JsonUtil`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> JsonUtil.hello()
      :world

  """
  def hello do
    :world
  end

  def query(json_text, query_expression) do
    expression_list = parse_query_expression(query_expression)
    json_text |> Jason.decode!
      |> probe_map(expression_list)
  end

  defp probe_map(item, expression_list, collected_items \\ []) do
    go_ahead = item |> is_list() or item |> is_map()
    go_ahead
      |> proceed(item, collected_items, fn x, res ->
        x |> Enum.reduce({res, expression_list}, fn entry, {cur_result, cur_expression} = same ->
          case entry do
            {k, v} ->
              case cur_expression do
                [first|rest] ->
                  if first == k do
                    case rest do
                      [_h|_t] -> {probe_map(v, rest, cur_result), rest}
                      [] -> {[v|cur_result], expression_list}
                    end
                  else
                    same
                  end
                [] -> # Exhausted
                  {[v|cur_result], expression_list}
              end
            atomic ->
              case cur_expression do
                [_first|_rest] ->
                  {cur_result, cur_expression}
                [] -> # Exhausted
                  {[atomic|cur_result], expression_list}
              end
          end
        end) |> elem(0)
      end)
  end

  defp parse_query_expression(query_expression) do
    query_expression |> String.split(".")
  end

  defp proceed(condition, item, result, function) do
    unless condition do
      result
    else
      function.(item, result)
    end
  end
end
