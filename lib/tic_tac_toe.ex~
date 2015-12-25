defmodule TicTacToe do
  use GenServer

  alias IO.ANSI
  alias TicTacToe.Helper

  @empty_token "-"
  @p1_token    "X"
  @p2_token    "O"

  def start_link, do: GenServer.start_link(__MODULE__, 3, name: __MODULE__)

  def state,      do: GenServer.call(__MODULE__, :state)

  # external API ^
  
  def init(board_size \\ 3) do
    board_size
    |> :math.pow(2)
    |> trunc
    |> Range.new(1)
    |> Enum.reduce(Map.new, fn(pos, board)->
      board
      |> Map.put(pos, @empty_token)
    end)
    |> Helper.wrap_pre(:ok)
  end

  def handle_call(:state, _from, board) do
    board
    |> IO.inspect
    |> Tuple.duplicate(2)
    |> Tuple.insert_at(0, :reply)
  end
  # helpers v
end

