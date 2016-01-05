defmodule TicTacToe.Board.StateMapBuilder do
  require Misc

  @min_board_size Misc.get_config(:min_board_size)
  @max_board_size Misc.get_config(:max_board_size)
  @move_lists     Misc.get_config(:move_lists)

  def build do
    @min_board_size..@max_board_size
    |> Enum.reduce(Map.new, fn(board_size, state_map)->
      valid_moves =
        @move_lists
        |> Map.get(board_size, move_list(board_size))

      row_chunks =
        valid_moves
        |> Enum.chunk(board_size)

      win_state =
        row_chunks
        |> win_sets

      {move_cells, move_map} =
        row_chunks
        |> printer_tup

      state_map
      |> Map.put(board_size, {valid_moves, win_state, move_map, move_cells})
    end)
  end

  #external API ^

  def printer_tup(row_chunks) do
    {rows, {move_map, _}} =
      row_chunks
      |> Enum.map_reduce({Map.new, 0}, fn(row_moves, {move_map, row_index})->
        row_key =
         "row_" 
          <> Integer.to_string(row_index)
          |> String.to_atom

        {cols, {move_map, _}} =
          row_moves
          |> Enum.map_reduce({move_map, 0}, fn(move, {move_map, col_index})->
            col_key =
             "col_" 
              <> Integer.to_string(col_index)
              |> String.to_atom

            move_map = 
              move_map
              |> Map.put(move, {row_key, col_key})

            {{col_key, move}, {move_map, col_index + 1}}
          end)

        {{row_key, cols}, {move_map, row_index + 1}}
      end)

    {rows, move_map}
  end

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
