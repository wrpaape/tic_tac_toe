defmodule TicTacToe.Computer do
  use GenServer

  alias TicTacToe.Board.EndGame

  def start_link(game_info), do: GenServer.start_link(__MODULE__, game_info, name: __MODULE__)

  def next_move(board_tup),  do: GenServer.call(__MODULE__, {:next_move, board_tup})

  def state,                 do: GenServer.call(__MODULE__, :state)


  # external api ^

  def init(turn_tup), do: {:ok, turn_tup}

  def handle_call(:state, _from, state), do: {:ok, state, state}

  def handle_call({:next_move, {board, valids, win_state}}, _from, chars) do
    board
    |> IO.write

    collector_pid =
      __MODULE__
      |> spawn_link(:collect, [nil, length(valids), self])
    

    valids
    |> Enum.reduce({[], valids}, fn(_move, {before_move, [move | after_move]})->
      __MODULE__
      |> spawn(:sum_branch, [move, before_move, after_move, win_state, chars,  collector_pid])

      {[move | before_move], after_move}
    end)

    receive do
      best_move ->
        best_move
        |> IO.write

      {:reply, best_move, chars}
    end
  end

  def do_branch(0,    _,    _,  _,    _,   _),   do: 0
  def do_branch(1,    me,   me, them, _,   _),   do: 1
  def do_branch(1,    them, me, them, _,   _),   do: -1
  def do_branch(wnst, me,   me, them, bef, aft), do: reduce_branch(wnst, them, me, them, bef ++ aft)
  def do_branch(wnst, them, me, them, bef, aft), do: reduce_branch(wnst, me,   me, them, bef ++ aft)

  def reduce_branch(win_state, next_up, me, them, rem_moves) do
    rem_moves
    |> Enum.reduce({0, [], rem_moves}, fn(_move, {acc_sum, before_move, [move | after_move]})->
      branch_sum = 
        move
        |> EndGame.next_win_state(next_up, win_state)
        |> do_branch(next_up, me, them, before_move, after_move)

      {acc_sum + branch_sum, [move | before_move], after_move}
    end)
    |> elem(0)
  end

  def sum_branch(move, before_move, after_move, win_state, {me, them}, collector_pid) do
    branch_score = 
      move
      |> EndGame.next_win_state(me, win_state)
      |> do_branch(me, me, them, before_move, after_move) 

    collector_pid
    |> send({branch_score, move})
  end

  # helpers v

  def collect({_, best_move}, 0, parent_pid),   do: send(parent_pid, best_move)
  def collect(last_best, rem_moves, parent_pid) do
    receive do
      move_sum ->
        move_sum 
        |> IO.inspect
        |> max(last_best)
        |> collect(rem_moves - 1, parent_pid)
    end
  end

  defp build_fact_sequence(open_rem_cells) do
    1..open_rem_cells
    |> Enum.scan(&(&1 * &2))
    |> Enum.reverse
    |> Enum.take_every(2)
    |> Mis.wrap_pre(:ok)
  end
end
