defmodule TicTacToe.Computer do
  use GenServer

  def start_link(game_info), do: GenServer.start_link(__MODULE__, game_info, name: __MODULE__)

  def next_move(board_tup),  do: GenServer.call(__MODULE__, {:next_move, board_tup})

  def state,                 do: GenServer.call(__MODULE__, :state)


  # external api ^

  def init(turn_tup), do: {:ok, turn_tup}

  def handle_call(:state, _from, state), do: {:ok, state, state}

  def handle_call({:next_move, {board, valids, win_state}}, _from, {c_char, p_char, [fact | rem_facts]}) do
    board
    |> IO.write

    move = Enum.random(valids)

    IO.puts move

    {:reply, move, {c_char, p_char, rem_facts}}
  end

  # helpers v

  defp build_fact_sequence(open_rem_cells) do
    1..open_rem_cells
    |> Enum.scan(&(&1 * &2))
    |> Enum.reverse
    |> Enum.take_every(2)
    |> Mis.wrap_pre(:ok)
  end
end
