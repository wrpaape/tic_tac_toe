defmodule TicTacToe.Player do
  alias IO.ANSI 
  alias TicTacToe.Board.Printer
  
  require Misc

  @cursor        Misc.get_config(:cursor)
  @select_prompt "\n\nplayer move:" <> @cursor
  
  @invalid_prompt ANSI.red       <> "\n\ninvalid move: "                <> ANSI.blink_slow
  @warning_prompt ANSI.blink_off <> "\n\nplease select from:\n\n  " <> ANSI.yellow

  def next_move(board, valid_moves) do
    move =
      board <> @select_prompt
      |> IO.gets
      |> String.first

    valid_moves
    |> Enum.member?(move)
    |> if do: move, else: redo(move, valid_moves, board)
  end

  def redo(move, valid_moves, board) do
    valid_moves_prompt =
      valid_moves
      |> inspect
      |> Misc.cap(@warning_prompt, ANSI.reset)

    move
    |> inspect
    |> Misc.cap(board <> @invalid_prompt, valid_moves_prompt)
    |> next_move(valid_moves)
  end
end
