defmodule TicTacToe.Board do
  use GenServer

  alias TicTacToe.Helper

  def start_link(board_size), do: GenServer.start_link(__MODULE__, board_size, name: __MODULE__)

  def add_tokens(tokens), do: GenServer.cast(__MODULE__, tokens, name: __MODULE__)

  def state,                  do: GenServer.call(__MODULE__, :state)

  # external API ^
  
  def init(board_size \\ 3) do
    winning_moves =
      board_size
      |> calculate_winning_moves

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
      
    {board, open_moves, winning_moves}
    |> Helper.wrap_pre(:ok)
  end

  def handle_cast({:add_tokens, tokens}, state) do
    tokens  
    |> Stream.cycle
    |> 
  end

  def handle_call(:state, _from, board) do
    board
    |> IO.inspect
    |> Tuple.duplicate(2)
    |> Tuple.insert_at(0, :reply)
  end
  # helpers v

  def calculate_winning_moves(board_size) do
    
  end
end

