defmodule TicTacToe.Computer do
  use GenServer

  alias TicTacToe.Board.EndGame

  def start_link(game_info), do: GenServer.start_link(__MODULE__, game_info, name: __MODULE__)

  def next_move(board_tup),  do: GenServer.call(__MODULE__, {:next_move, board_tup})

  def state,                 do: GenServer.call(__MODULE__, :state)


  # external api ^

  def init({my_char, their_char}) do
    Map.new
    |> Map.put(1, my_char)
    |> Map.put(-1, their_char)
    |> Utils.wrap_pre(:ok)
  end

  def handle_call(:state, _from, state), do: {:ok, state, state}

  def handle_call({:next_move, {board, valids, win_state}}, _from, chars = %{1 => my_char}) do
    board
    |> IO.write

    collector_pid =
      __MODULE__
      |> spawn(:collect, [nil, length(valids), self])
    

    valids
    |> Enum.reduce_while({[], valids}, fn(_move, {before_move, [move | after_move]})->
      move
      |> EndGame.next_win_state(my_char, win_state) 
      |> case do
        1 ->
          self
          |> send(move)

          {:halt, :guaranteed_win}


        next_win_state ->
          next_win_state
          |> case do
            0 ->
              collector_pid
              |> send({0, move})

            _ ->
              __MODULE__
              |> spawn(:sum_branch, [next_win_state,
                                     chars,
                                     before_move,
                                     after_move,
                                     collector_pid,
                                     move])
          end

          {:cont, {[move | before_move], after_move}}
      end
    end)

    receive do
      best_move ->
        best_move
        |> IO.write

        collector_pid
        |> Process.exit(:kill)

      {:reply, best_move, chars}
    end
  end

  def do_branch(done, mult, _, _, _) when is_number(done),       do: done * mult
  def do_branch(win_state, mult, chars, before_move, after_move) do
    before_move
    |> Enum.concat(after_move)
    |> reduce_branch(mult * -1, chars, win_state)
  end

  def reduce_branch(rem_moves, mult, chars, win_state) do
    next_char =
      chars
      |> Map.get(mult)

    rem_moves
    |> Enum.reduce({0, [], rem_moves}, fn(_move, {acc_sum, before_move, [move | after_move]})->
      branch_sum = 
        move
        |> EndGame.next_win_state(next_char, win_state)
        |> do_branch(mult, chars, before_move, after_move)

      {acc_sum + branch_sum, [move | before_move], after_move}
    end)
    |> elem(0)
  end


  def sum_branch(win_state, chars, before_move, after_move, collector_pid, move) do
    branch_sum =
      win_state
      |> do_branch(1, chars, before_move, after_move)

    collector_pid
    |> send({branch_sum, move})

    exit(:kill)
  end

  # helpers v

  def collect({_, best_move}, 0, parent_pid),  do: send(parent_pid, best_move)
  def collect(last_max, rem_moves, parent_pid) do
    receive do
      move_sum ->
        move_sum 
        |> IO.inspect
        |> max(last_max)
        |> collect(rem_moves - 1, parent_pid)
    end
  end
end
