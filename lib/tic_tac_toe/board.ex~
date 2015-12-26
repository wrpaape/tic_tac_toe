defmodule TicTacToe.Board do
  use GenServer

  alias IO.ANSI
  alias TicTacToe.Helper

  @tokens ~w(X O)

  def start_link(board_size), do: GenServer.start_link(__MODULE__, board_size, name: __MODULE__)

  def state,                  do: GenServer.call(__MODULE__, :state)

  # external API ^
  
  def init(board_size \\ 3) do
    open_moves =
      board_size
      |> :math.pow(2)
      |> trunc
      |> Range.new(1)
      |> Enum.reduce([], fn(pos, moves)->
       [Integer.to_string(pos) | moves] 
      end)

    board =
      open_moves
      |> Enum.map(&{&1, &1})
      
    {board, open_moves, [], [], Enum.random(@tokens)}
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

