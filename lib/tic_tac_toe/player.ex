defmodule TicTacToe.Player do
  alias IO.ANSI 
  alias TicTacToe.Helper
  
  @warning "invalid move, please select from:\n  "
    |> Helper.cap(ANSI.red, ANSI.bright <> ANSI.yellow)
end
