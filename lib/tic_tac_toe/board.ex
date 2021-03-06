defmodule TicTacToe.Board do
  use GenServer

  require Utils

  @select_prompt " move:" <> Utils.get_config(:cursor)

  alias __MODULE__.{EndGame, InitialState, Printer}
  alias  TicTacToe.{Computer, Player}

  def start_link(board_size), do: GenServer.start_link(__MODULE__, board_size, name: __MODULE__)

  def state,                  do: GenServer.call(__MODULE__, :state)

  def next_move(player_tup),  do: GenServer.call(__MODULE__, {:next_move, player_tup}, :infinity)

  # external API ^
  
  def init(board_size) do
    {printer_tup, board_tup} =
      board_size
      |> InitialState.get

    printer_tup
    |> Printer.start_link

    {:ok, board_tup}
  end

  def handle_call(:state, _from, state), do: {:reply, state, state}

  def handle_call({:next_move, {player, token = {_, char}}}, _from, state = {valid_moves, win_state}) do
    next_move =
      player
      |> apply_next_move(Printer.print, valid_moves, win_state)

    next_move
    |> Printer.update(token)

    next_move
    |> EndGame.next_win_state(char, win_state)
    |> case do
      0 -> {:tie, []}
      1 -> {:win, []} 
      next_win_state -> {:cont, next_win_state}
    end
    |> reply_next(List.delete(valid_moves, next_move))
  end

  def reply_next({msg, next_win_state}, next_valid_moves) do
    {:reply, msg, {next_valid_moves, next_win_state}}
  end

  # helpers v

  defp apply_next_move(Computer, board, valid_moves, win_state) do
    {[board, "\n\ncomputer", @select_prompt], valid_moves, win_state}
    |> Computer.next_move
  end

  defp apply_next_move(Player, board, valid_moves, _) do
    board
    |> Player.next_move(valid_moves, ["\n\nplayer", @select_prompt])
  end
end

