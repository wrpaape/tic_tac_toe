defmodule TicTacToe.Board.StateMapBuilder do
  require Misc
  
  @min_board_size Misc.get_config(:min_board_size)
  @max_board_size Misc.get_config(:max_board_size)
  
  def build do
    @min_board_size..@max_board_size
    |> Enum.reduce(Map.new, fn(board_size, state_map)->
      valid_moves = 
        board_size
        |> move_list

      win_state =
        valid_moves
        |> Enum.chunk(board_size)
        |> win_sets

      board =
        valid_moves
        |> Enum.map(&{&1, Integer.to_string(&1)})
        |> Enum.chunk(board_size)
        
      state_map
      |> Map.put(board_size, {valid_moves, win_state, board})
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

  defp move_list(board_size), do: Enum.to_list(1..last_cell(board_size))

  defp last_cell(board_size) do
    board_size
    |> :math.pow(2)
    |> trunc
  end
end
