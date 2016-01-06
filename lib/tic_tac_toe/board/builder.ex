defmodule TicTacToe.Board.Builder do
  require Misc
  
  @dir Misc.get_config(:root_path)
    |> Misc.get_module_dir

end
