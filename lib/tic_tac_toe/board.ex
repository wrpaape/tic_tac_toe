defmodule TicTacToe.Board do
  use GenServer
  
  alias TicTacToe.Board.Printer
  alias TicTacToe.Board.StateMapBuilder

  @state_map StateMapBuilder.build

  def start_link(board_size), do: GenServer.start_link(__MODULE__, board_size, name: __MODULE__)

  def state,                  do: GenServer.call(__MODULE__, :state)

  def next_move(player_tup),  do: GenServer.call(__MODULE__, {:next_move, player_tup}, :infinity)

  def next_win_state(move, token, win_state), do: next_info(move, token, win_state, [])

  # external API ^
  
  def init(board_size) do
    {valid_moves, win_state, move_map, move_cells} =
      @state_map
      |> Map.get(board_size)

    {move_map, move_cells, board_size}
    |> Printer.start_link

    {:ok, {valid_moves, win_state}}
  end

  def handle_call(:state, _from, state), do: {:reply, state, state}

  def handle_call({:next_move, {player, token = {_, char}}}, _from, state = {valid_moves, win_state}) do
    next_move =
      player
      |> apply(:next_move, [Printer.print, valid_moves, win_state])
      
    next_move
    |> Printer.update(token)

    next_move
    |> next_win_state(char, win_state)
    |> case do
      {:game_over, go_msg} ->
        Printer.print
        |> IO.write

        {:stop, :normal, go_msg, state}

      next_win_state -> 
        {:reply, :cont, {List.delete(valid_moves, next_move), next_win_state}}
    end
  end

  # helpers v

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
        %HashSet{size: 0}           -> {:game_over, var!(token) <> " W I N S !"}
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

  def next_info(_move, _token, [], []),             do: {:game_over, "C A T ' S   G A M E"}
  def next_info(_move, _token, [], next_win_state), do: next_win_state
end

