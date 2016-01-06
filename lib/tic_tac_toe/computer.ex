defmodule TicTacToe.Computer do
  use GenServer

  require Misc

  @cursor Misc.get_config(:cursor)
  @prompt "computer move:" <> @cursor
  @max_moves Misc.get_config(:max_board_size)
    |> Misc.int_pow(2)
  # @fact_cache 0..(:max_board_size |> Misc.get_config |> Misc.
  #   |> Misc.int_pow(2)
  #   |> Range.new(0)
  #   |> Enum.rev
  #   |> Enum.to_list
  #   |> List.foldr(%{0 => 1}, &Map.put(&2, &1, &1 * &2[&1 - 1]))


  def start_link(opening_move_tup), do: GenServer.start_link(__MODULE__, opening_move_tup, name: __MODULE__)

  def state,                  do: GenServer.call(__MODULE__, :state)

  def init(board_size, turn_offset) do
    1
    |> Range.new(board_size * board_size - turn_offset)
    |> Enum.scan(&(&1 * &2))
    |> Enum.reverse
    |> Enum.take_every(2)
    |> Mis.wrap_pre(:ok)
  end

  def next_move(valid_moves, win_state) do
    valid_moves
    |> Enum.each(fn(move)->
      
      
    end)

    # @prompt
    # |> IO.gets
    # |> String.first
  end
end
