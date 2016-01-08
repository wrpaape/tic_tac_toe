defmodule TicTacToe.Player do
  alias IO.ANSI 
  alias TicTacToe.Board.Printer
  
  require Utils
  
  @invalid_prompt ANSI.red       <> "\n\ninvalid move: "            <> ANSI.blink_slow
  @warning_prompt ANSI.blink_off <> "\n\nplease select from:\n\n  " <> ANSI.yellow

  def next_move(board, valid_moves, prompt) do
    move =
      [board | prompt]
      |> IO.gets
      |> String.first

    valid_moves
    |> Enum.member?(move)
    |> if(do: move, else: redo(move, valid_moves, board))
  end

  def redo(move, valid_moves, board) do
    valid_moves_prompt =
      valid_moves
      |> inspect
      |> Utils.cap(@warning_prompt, ANSI.reset)

    board
    |> next_move(valid_moves, [@invalid_prompt, inspect(move), valid_moves_prompt])
  end
end
