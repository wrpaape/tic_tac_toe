defmodule TicTacToe.Board.MoveMapBuilder do
  alias TicTacToe.Helper

  def build do
    size_range =
      ~w(min_size max_size)a
      |> Enum.map(&apply(Helper, :get_config, [&1]))

    Range
    |> apply(:new, size_range)
    |> Enum.reduce(Map.new, fn(size, move_map)->
      move_list = 
        size
        |> move_list
      
      move_tup =
        move_list
        |> Enum.chunk(size)
        |> winning_moves
        |> Helper.wrap_app(Enum.map(move_list, &{&1, &1}))
        |> Tuple.append(Enum.into(move_list, HashSet.new))
      
      move_map
      |> Map.put(size, move_tup)
    end)
  end

  #external API ^

  def winning_moves(row_chunks) do
    rows =
      row_chunks
      |> Enum.reduce(HashSet.new, fn(chunk, rows)->
        rows
        |> Set.put(Enum.into(chunk, HashSet.new))
      end)
      
    rows_cols =
      row_chunks
      |> List.zip
      |> Enum.reduce(rows, fn(chunk_tup, rows_cols)->
        next_cols =
          chunk_tup 
          |> Tuple.to_list
          |> Enum.into(HashSet.new)

        rows_cols
        |> Set.put(next_cols)
      end)

    row_chunks
    |> Enum.reduce([{HashSet.new, 0, 1}, {HashSet.new, -1, -1}], fn(chunk, diag_tups)->
      diag_tups
      |> Enum.map(fn({diag, at, inc})->
        diag
        |> Set.put(Enum.at(chunk, at)) 
        |> Helper.wrap_app(at + inc)
        |> Tuple.append(inc)
      end)
    end)
    |> Enum.reduce(rows_cols, fn({diag, _, _}, winning_moves)->
      winning_moves
      |> Set.put(diag)
    end)
  end

  def move_list(size) do
    size
    |> :math.pow(2)
    |> trunc
    |> Range.new(1)
    |> Enum.reduce([], fn(pos, moves)->
      [Integer.to_string(pos) | moves] 
    end)
  end
end