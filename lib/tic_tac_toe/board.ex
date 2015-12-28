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

  def next_win_state(move, token, win_state), do: next_win_info(move, token, win_state, [])

  # external API ^
  
  def init(size) do
    @move_map
    |> Map.get(size)
    |> Helper.wrap_pre(:ok)
  end

  def handle_call({:next_move, {Player, token}}, _from, {win_tups, board, valid_moves}) do
    valid_moves
    |> Player.next_move
    |> next_win_state(token, win_tups)

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
  
  defmacrop recurse(next_win_info) do
    quote do
      var!(acc_win_state) = [unquote(next_win_info) | var!(acc_win_state)]

      recurse
    end
  end

  defmacrop recurse do
    quote do
      next_win_info(var!(move), var!(token), var!(rem_win_state), var!(acc_win_state))
    end
  end

  defmacrop reduce_owned_or_unclaimed_win_info_and_recurse do
    quote do
      var!(win_set)
      |> Set.delete(var!(move))
      |> case do
        %HashSet{size: ^var!(size)} -> recurse(var!(win_info))
        %HashSet{size: 0}           -> :win
        next_win_set                -> recurse({next_win_set, var!(token)})
      end
    end
  end

  def next_win_info(move, token, [win_info = {win_set = %HashSet{size: size}, token} | rem_win_state], acc_win_state) do
    reduce_owned_or_unclaimed_win_info_and_recurse
  end

  def next_win_info(move, token, [win_info = win_set = %HashSet{size: size} | rem_win_state], acc_win_state) do
    reduce_owned_or_unclaimed_win_info_and_recurse
  end

  def next_win_info(move, token, [occ_win_info | rem_win_state], acc_win_state) do
    occ_win_info
    |> elem(0)
    |> Set.member?(move)
    |> if do: recurse, else: recurse(occ_win_info)
  end

  def next_win_info(_move, _token, [], []),             do: :tie
  def next_win_info(_move, _token, [], next_win_state), do: next_win_state
end

