defmodule TicTacToe.Board.StateMapBuilder do
  require Misc

  alias TicTacToe.Board

  @min_board_size  Misc.get_config(:min_board_size)
  @max_board_size  Misc.get_config(:max_board_size)
  @move_lists      Misc.get_config(:move_lists)
  @max_num_cells   @max_board_size * @max_board_size
  @timeout         1000
  @factorial_cache 1..@max_board_size
    |> Enum.scan(&(&1 * &2))
    |> Enum.reverse

  def build do
    @min_board_size..@max_board_size
    |> Enum.reduce(Map.new, fn(board_size, state_map)->
      num_cells = board_size * board_size

      valid_moves =
        @move_lists
        |> Map.get_lazy(board_size, fn ->
          num_cells
          |> def_move_list
        end)

      row_chunks =
        valid_moves
        |> Enum.chunk(board_size)

      win_state =
        row_chunks
        |> win_sets

      outcome_counts =
        valid_moves
        |> num_possible_outcomes_by_turn(win_state)

      {move_cells, move_map} =
        row_chunks
        |> printer_tup

      state_map
      |> Map.put(board_size, {valid_moves, win_state, outcome_counts, move_map, move_cells})
    end)
  end

  #external API ^

  def collector(root_pid) do
    countdown = fn ->
      @timeout
      |> :timer.send_after({:return, root_pid})
      |> elem(1)
    end

    Map.new
    |> collect(countdown.(), countdown)
  end

  def collect(results, tref, countdown) do
    receive do
      {:return, root_pid} ->
        root_pid
        |> send(results)

      {:record, turn} ->
        tref
        |> :timer.cancel

        results
        |> Map.update(turn, 1, &(&1 + 1))
        |> collect(countdown.(), countdown)
    end
  end

  def recurse(rem_moves, token, win_state, turn, collector_pid) do
    rem_moves
    |> Enum.reduce({[], tl(rem_moves)}, fn(move, {other_before, other_after})->
      move
      |> Board.next_win_state(token, win_state)
      |> case do
        end_game when is_number(end_game) -> 
          collector_pid
          |> send({:record, turn})

        next_win_state ->
          __MODULE__
          |> spawn(:recurse, [other_before ++ other_after, not token, next_win_state, turn + 1, collector_pid])
      end

      {[move | other_before], tl(other_after)}
    end)
  end

  def num_possible_outcomes_by_turn(valid_moves, win_state) do
    collector_pid =
      __MODULE__
      |> spawn(:collector, [self])

    __MODULE__
    |> spawn(:recurse, [valid_moves, true, win_state, 1, collector_pid])


    receive do
      results -> 
        results
        |> Enum.sort(&>=/2)
        |> Enum.map(&elem(&1, 1))
      
      # after 5000 -> throw("taking too long")
    end
  end

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

  defp def_move_list(num_cells), do: Enum.map(1..num_cells, &Integer.to_string/1)
end
