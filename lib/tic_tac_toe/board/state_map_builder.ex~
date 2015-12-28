defmodule TicTacToe.Board.StateMapBuilder do
  require Misc
  
  @min_size Misc.get_config(:min_size)
  @max_size Misc.get_config(:max_size)
  
  def build do
    @min_size..@max_size
    |> Enum.reduce(Map.new, fn(size, state_map)->
      valid_moves = 
        size
        |> move_list

      win_state =
        valid_moves
        |> Enum.chunk(size)
        |> win_sets

      board =
        valid_moves
        |> Enum.map(&{&1, Integer.to_string(&1)})
        |> Enum.chunk(size)
        
      state_map
      |> Map.put(size, {valid_moves, win_state, board})
    end)
  end

  #external API ^

  def win_sets(row_chunks) do
    rows =
      row_chunks
      |> Enum.map(&Enum.into(&1, HashSet.new))
      
    rows_cols =
      row_chunks
      |> List.zip
      |> Enum.reduce(rows, fn(chunk_tup, rows_cols)->
        chunk_tup 
        |> Tuple.to_list
        |> Enum.into(HashSet.new)
        |> Misc.push_in(rows_cols)
      end)

    row_chunks
    |> Enum.reduce([{HashSet.new, 0, 1}, {HashSet.new, -1, -1}], fn(chunk, diag_tups)->
      diag_tups
      |> Enum.map(fn({diag, at, inc})->
        diag
        |> Set.put(Enum.at(chunk, at)) 
        |> Misc.wrap_app(at + inc)
        |> Tuple.append(inc)
      end)
    end)
    |> Enum.reduce(rows_cols, &[elem(&1, 0) | &2])
  end

  defp move_list(size), do: Enum.to_list(1..last_cell(size))

  defp last_cell(size) do
    size
    |> :math.pow(2)
    |> trunc
  end
end
