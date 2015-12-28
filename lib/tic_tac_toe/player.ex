defmodule TicTacToe.Player do
  alias IO.ANSI 
  alias TicTacToe.Helper
  
  @warning "invalid move, please select from:\n  "
    |> Helper.cap(ANSI.red, ANSI.bright <> ANSI.yellow)

      # {:invalid, valid_moves} -> 
      #   valid_moves
      #   |> inspect
      #   |> Helper.cap(@warning, ANSI.reset)
      #   |> IO.puts

      #   player_tup
      #   |> next_move(next_turn)

  def next_move(valid_moves, _win_state) do
    
  end
end
