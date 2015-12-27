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

  def next_win_tups(move, token, win_tups), do: next_win_tup(move, token, win_tups, [])

  # external API ^
  
  def init(size) do
    @move_map
    |> Map.get(size)
    |> Helper.wrap_pre(:ok)
  end

  def handle_call({:next_move, {Player, token}}, _from, {win_tups, board, valid_moves}) do
    valid_moves
    |> Player.next_move
    |> nex_win_set(token, win_tups)

      # {:invalid, valid_moves} -> 
      #   valid_moves
      #   |> inspect
      #   |> Helper.cap(@warning, ANSI.reset)
      #   |> IO.puts

      #   player_tup
      #   |> next_move(next_turn)
  end


  def handle_call({:next_move, {Computer, token}}, _from, {win_tups, board, valid_moves}) do

  end

  def handle_call(:state, _from, board) do
    board
    |> Tuple.duplicate(2)
    |> Tuple.insert_at(0, :reply)
  end

  # helpers v

  def next_win_tup(move, token, [win_tup = {open_win_set, size} | rem_win_tups], next_win_tups) do
    next_win_tups =
      move
      |> Set.member?(open_win_set)
      |> if do: {open_win_set, token, size - 1}, else: win_tup
      |> Helper.push_in(next_win_tups)

    next_win_tups(move, token, rem_win_tups, next_win_tups)
  end
  

  def next_win_tup(_move, _token, [], next_win_tups), do: next_win_tups
    # win_tups
    # |> Enum.reduce_while([], fn
    #   (->
        
    #   (own_win_set, ^token, size}, next_win_tups)->
    #     move
    #     |> Set.member?(own_win_set)
    #     |> if do: size - 1, else: size
    # end)

end

