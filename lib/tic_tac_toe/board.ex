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

  def next_win_state(move, token, win_state), do: next_info(move, token, win_state, [])

  # external API ^
  
  def init(size) do
    @move_map
    |> Map.get(size)
    |> Tuple.append(size)
    |> Helper.wrap_pre(:ok)
  end

  def handle_call({:next_move, {Player, token}}, _from, {win_state, board, valid_moves, size, }) do
    next_move =
      valid_moves
      |> Player.next_move
      
    next_board =
      next_move
      |> update_board(token, board, [])

    |> next_win_state(token, win_state)

      # {:invalid, valid_moves} -> 
      #   valid_moves
      #   |> inspect
      #   |> Helper.cap(@warning, ANSI.reset)
      #   |> IO.puts

      #   player_tup
      #   |> next_move(next_turn)
  end


  def handle_call({:next_move, {Computer, token}}, _from, {win_state, board, valid_moves}) do

  end

  def handle_call(:state, _from, board) do
    board
    |> Tuple.duplicate(2)
    |> Tuple.insert_at(0, :reply)
  end

  # helpers v

  def
  def update_board(move, token, [next_row | rem_rows], acc_rows) do
    board
  end
  
  defmacrop recurse(next_acc_state) do
    quote do
      next_info(var!(move), var!(token), var!(rem_state), unquote(next_acc_state))
    end
  end

  defmacrop push_next(next_info) do
    quote do: recurse([unquote(next_info) | var!(acc_state)])
  end

  defmacrop reduce_owned_or_unclaimed_info_and_recurse do
    quote do
      var!(win_set)
      |> Set.delete(var!(move))
      |> case do
        %HashSet{size: ^var!(size)} -> push_next(var!(info))
        %HashSet{size: 0}           -> :win
        next_win_set                -> push_next({next_win_set, var!(token)})
      end
    end
  end

  def next_info(move, token, [info = {win_set = %HashSet{size: size}, token} | rem_state], acc_state) do
    reduce_owned_or_unclaimed_info_and_recurse
  end

  def next_info(move, token, [info = win_set = %HashSet{size: size} | rem_state], acc_state) do
    reduce_owned_or_unclaimed_info_and_recurse
  end

  def next_info(move, token, [occ_info | rem_state], acc_state) do
    occ_info
    |> elem(0)
    |> Set.member?(move)
    |> if do: recurse(acc_state), else: push_next(occ_info)
  end

  def next_info(_move, _token, [], []),             do: :tie
  def next_info(_move, _token, [], next_win_state), do: next_win_state
end

