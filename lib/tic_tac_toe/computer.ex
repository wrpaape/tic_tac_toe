defmodule TicTacToe.Computer do
  require Misc

  @cursor Misc.get_config(:cursor)
  @prompt "computer move:" <> @cursor

  def next_move(valid_moves, win_state) do

    @prompt
    |> IO.gets
    |> String.first
  end
end
