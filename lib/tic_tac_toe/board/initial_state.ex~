defmodule TicTacToe.Board.InitialState do
  require Utils

  alias TicTacToe.Board.EndGame
  
  @dir             Utils.module_path
  @fun_names      ~w(valid_moves win_state move_map move_cells)a
  @min_board_size  Utils.get_config(:min_board_size)
  @max_board_size  Utils.get_config(:max_board_size)
  @move_lists      Utils.get_config(:move_lists)
  @max_num_cells   @max_board_size * @max_board_size
  @timeout         1000
  @factorial_cache 1..@max_board_size
    |> Enum.scan(&(&1 * &2))
    |> Enum.reverse

  def get(size) do
    size_module =
      __MODULE__
      |> Module.concat("BoardSize" <> Integer.to_string(size))

    @fun_names
    |> Enum.map(&{&1, apply(size_module, &1, [])})
  end

  def clean do
   @dir 
   |> Path.join("**")
   |> Path.wildcard
   |> Enum.each(&File.rm_rf!/1)
  end

  def build do
    @min_board_size..@max_board_size
    |> Enum.each(&build_state/1)
  end

  #external API ^

  def build_state(board_size) do
    num_cells = board_size * board_size

    valid_moves =
      @move_lists
      |> Map.get_lazy(board_size, fn ->
        num_cells
        |> default_move_list
      end)

    row_chunks =
      valid_moves
      |> Enum.chunk(board_size)

    win_state =
      row_chunks
      |> win_lists

    # outcome_counts =
    #   valid_moves
    #   |> num_possible_outcomes_by_turn(win_state)

    {move_cells, move_map} =
      row_chunks
      |> printer_tup

    file_content =
      [valid_moves, win_state, move_cells, move_map]
      |> Enum.map_reduce(@fun_names, fn(content, [name | rem_names])->
        content
        |> inspect(pretty: true, as_lists: true) 
        |> Utils.wrap_pre(name)
        |> Utils.wrap_app(rem_names)
      end)
      |> elem(0)
      |> Keyword.update!(:win_state, &(&1 <> "\n|> Enum.map(&Enum.into(&1, HashSet.new))"))
      |> Enum.map_join("\n\n", fn({name, content})->
        content
        |> String.replace(~r/^/m, "    ")
        |> Utils.cap("  def #{name} do\n", "\n  end")
      end)
      |> Utils.cap("defmodule #{__MODULE__}.BoardSize#{board_size} do\n", "\nend")

    file_name =
      board_size
      |> Integer.to_string
      |> Utils.cap("board_size_", ".ex")

    @dir
    |> Path.join(file_name)
    |> File.write(file_content)
  end

  def collector(root_pid) do
    countdown = fn ->
      @timeout
      |> :timer.send_after({:return, root_pid})
      |> elem(1)
    end

    Map.new
    |> collect(countdown.(), countdown)
  end

  # def collect(results, tref, countdown) do
  #   receive do
  #     {:return, root_pid} ->
  #       root_pid
  #       |> send(results)

  #     {:record, turn} ->
  #       tref
  #       |> :timer.cancel

  #       results
  #       |> Map.update(turn, 1, &(&1 + 1))
  #       |> collect(countdown.(), countdown)
  #   end
  # end

  # def recurse(rem_moves, token, win_state, turn, collector_pid) do
  #   rem_moves
  #   |> Enum.reduce({[], tl(rem_moves)}, fn(move, {other_before, other_after})->
  #     move
  #     |> Board.next_win_state(token, win_state)
  #     |> case do
  #       end_game when is_integer(end_game) -> 
  #         collector_pid
  #         |> send({:record, turn})

  #       next_win_state ->
  #         __MODULE__
  #         |> spawn(:recurse, [other_before ++ other_after, not token, next_win_state, turn + 1, collector_pid])
  #     end

  #     {[move | other_before], tl(other_after)}
  #   end)
  # end

  # def num_possible_outcomes_by_turn(valid_moves, win_state) do
  #   collector_pid =
  #     __MODULE__
  #     |> spawn(:collector, [self])

  #   __MODULE__
  #   |> spawn(:recurse, [valid_moves, true, win_state, 1, collector_pid])

  #   receive do
  #     results -> 
  #       results
  #       |> Enum.sort(&>=/2)
  #       |> Enum.map(&elem(&1, 1))
      
  #     # after 5000 -> throw("taking too long")
  #   end
  # end

  def merge_branch([], branch_hist),         do: Enum.reverse(branch_hist)
  def merge_branch(child_hists, branch_hist) do
    {gos_this_turn, next_child_hists} =
      child_hists
      |> Enum.reduce({0, []},fn
        ({gos_this_turn, next_child_hists}, [head | tail]})->
          {gos_this_turn + head, [tail | next_child_hists]}

        (acc_tup, []})->
          acc_tup
      end)

    next_child_hists
    |> merge_branch([gos_this_turn | branch_hist])
  end

  def collect(gos_this_turn, acc_go_hist, 0, parent_pid) do
    branch_go_hist = 
      branch_go_hist
      |> merge_branch([gos_this_turn])

    parent_pid
    |> send({:game_over_history, go_hist})
  end

  def collect(gos_this_turn, acc_go_hist, rem_branches, parent_pid) do
    receive do
      :game_over
        gos_this_turn
        |> + 1
        |> collect(acc_go_hist, rem_branches - 1, parent_pid)

      {:game_over_history, child_go_hist} ->
        gos_this_turn
        |> collect([child_go_hist | acc_go_hist], rem_branches - 1, parent_pid)
    end
  end

  def recurse(rem_moves, num_rem, token, win_state, turn, collector_pid) do
    rem_moves
    |> Enum.reduce({[], tl(rem_moves)}, fn(move, {other_before, other_after})->
      move
      |> EndGame.next_win_state(token, win_state)
      |> case do
        end_game when is_integer(end_game) -> 
          collector_pid
          |> send(:game_over)

        next_win_state ->
          __MODULE__
          |> spawn(:recurse, [other_before ++ other_after, num_rem - 1, not token, next_win_state, collector_pid])
      end

      {[move | other_before], tl(other_after)}
    end)
  end

  def num_possible_outcomes_by_turn(valid_moves, win_state) do
    num_rem =
      valid_moves
      |> length

    collector_pid =
      __MODULE__
      |> spawn(:collect, [0, [], num_rem, self])

    __MODULE__
    |> spawn(:recurse, [valid_moves, num_rem, true, win_state, 1, collector_pid])

    receive do
      {:game_over_history, game_over_history} ->
        game_over_history
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

  def win_lists(cell_chunk = [[_]]), do: cell_chunk
  def win_lists(row_chunks)          do
    ~w(rows_and_columns diagonals)a
    |> Enum.flat_map(fn(fun)->
      __MODULE__
      |> apply(fun, [row_chunks])
    end)
  end

  def rows_and_columns(row_chunks) do
    row_chunks
    |> List.zip
    |> Enum.reduce(row_chunks, &[Tuple.to_list(&1) | &2])
  end

  def diagonals(row_chunks) do
    row_chunks
    |> Enum.reduce([{[], 0, 1}, {[], -1, -1}], fn(chunk, diag_tups)->
      diag_tups
      |> Enum.map(fn({diag, n, inc})->
        chunk
        |> Enum.at(n)
        |> Utils.push_in(diag)
        |> Utils.wrap_app(n + inc)
        |> Tuple.append(inc)
      end)
    end)
    |> Enum.map(&elem(&1, 0))
  end

  def default_move_list(num_cells) do
    0..(num_cells - 1)
    |> Enum.map(fn(int)->
      int
      |> inspect(base: :hex)
      |> String.slice(2..-1)
      |> String.downcase
    end)
  end
end
