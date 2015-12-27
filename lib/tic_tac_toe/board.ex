defmodule TicTacToe.Board do
  use GenServer

  alias IO.ANSI
  alias TicTacToe.Helper
  alias TicTacToe.Player
  alias TicTacToe.Computer

  @move_map __MODULE__
    |> Module.safe_concat(MoveMapBuilder)
    |> apply(:build, [])

  @tie_prompt Helper.fun_prompt("C A T ' S   G A M E")

  def start_link(size),      do: GenServer.start_link(__MODULE__, size, name: __MODULE__)

  def next_move(player_tup), do: GenServer.call({:next_move, player_tup})

  def state,                 do: GenServer.call(__MODULE__, :state)

  # external API ^
  
  def init(size) do
    @move_map
    |> Map.get(size)
    |> Helper.wrap_pre(:ok)
  end

  def handle_call({:next_move, {Player, token}}, _from, {win_sets, board, valid_moves}) do
      # {:invalid, valid_moves} -> 
      #   valid_moves
      #   |> inspect
      #   |> Helper.cap(@warning, ANSI.reset)
      #   |> IO.puts

      #   player_tup
      #   |> next_move(next_turn)
  end

  def handle_call({:next_move, {Computer, token}}, _from, {win_sets, board, valid_moves}) do

  end

  def handle_call(:state, _from, board) do
    board
    |> Tuple.duplicate(2)
    |> Tuple.insert_at(0, :reply)
  end

  # helpers v
end

