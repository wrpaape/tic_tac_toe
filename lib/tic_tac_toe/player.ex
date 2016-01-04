defmodule TicTacToe.Player do
  alias IO.ANSI 
  
  require Misc
  
  @warning "invalid move, please select from:\n  "
    |> Misc.cap(ANSI.red, ANSI.bright <> ANSI.yellow)

      # {:invalid, valid_moves} -> 
      #   valid_moves
      #   |> inspect
      #   |> Misc.cap(@warning, ANSI.reset)
      #   |> IO.puts

      #   player_tup
      #   |> next_move(next_turn)

  def next_move(valid_moves, _win_state) do
    
    IO.getn("next_move")
  end
end
