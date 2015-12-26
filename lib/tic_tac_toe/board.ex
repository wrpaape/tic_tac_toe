defmodule TicTacToe.Board do
  use GenServer

  alias TicTacToe.Helper
  require TicTacToe.Board.Initializer

  @move_map __MODULE__
    |> Module.concat(Initializer)
    |> apply(:move_map, [])

  def start_link(size), do: GenServer.start_link(__MODULE__, size, name: __MODULE__)

  def add_tokens(tokens), do: GenServer.cast(__MODULE__, tokens, name: __MODULE__)

  def state,                  do: GenServer.call(__MODULE__, :state)

  # external API ^
  
  def init(size) do
    @move_map
    |> Map.get(size)
    |> Helper.wrap_pre(:ok)
  end

  # def handle_cast({:add_tokens, tokens}, state) do
  #   tokens  
  #   |> Stream.cycle
  #   |> 
  # end

  def handle_call(:state, _from, board) do
    board
    |> IO.inspect
    |> Tuple.duplicate(2)
    |> Tuple.insert_at(0, :reply)
  end

  # helpers v
end

