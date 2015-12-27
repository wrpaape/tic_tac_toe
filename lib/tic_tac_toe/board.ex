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
    |> next_win_tups(token, win_tups)

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

  defmacrop recurse(next_acc_win_tups) do
    quote do
      next_win_tup(var!(move), var!(token), var!(rem_win_tups), unquote(next_acc_win_tups))
    end
  end

  defmacrop reduce_owned_or_unclaimed_win_tup_and_recurse do
    quote do
      var!(win_set)
      |> Set.member?(var!(move))
      |> if do
        {Set.delete(var!(win_set), var!(move)), var!(token), var!(size) - 1}
      else
        var!(win_tup)
      end
      |> Helper.push_in(var!(acc_win_tups))
      |> recurse
    end
  end

  def next_win_tup(move, token, [own_win_tup = {win_set, token, 1} | rem_win_tups], acc_win_tups) do
    win_set
    |> Set.member?(move)
    |> if do: :win, else: recurse([own_win_tup | acc_win_tups])
  end

  def next_win_tup(move, token, [win_tup = {win_set, token, size} | rem_win_tups], acc_win_tups) do
    reduce_owned_or_unclaimed_win_tup_and_recurse 
  end

  def next_win_tup(move, token, [win_tup = {win_set, size} | rem_win_tups], acc_win_tups) do
    reduce_owned_or_unclaimed_win_tup_and_recurse 
  end

  def next_win_tup(move, token, [occ_win_tup | rem_win_tups], acc_win_tups) do
    occ_win_tup
    |> elem(0)
    |> Set.member?(move)
    |> if do
      acc_win_tups
    else
      [occ_win_tup | acc_win_tups];
    end
    |> recurse
  end

  def next_win_tup(_move, _token, [], []),            do: :tie
  def next_win_tup(_move, _token, [], next_win_tups), do: next_win_tups
  # def next_win_tup(_move, _token, [], next_win_tups), do: IO.puts "HI"
end

