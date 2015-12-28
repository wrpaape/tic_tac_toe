defmodule TicTacToe.Board.Printer do
  use GenServer

  require Misc

  def start_link(size), do: GenServer.start_link(__MODULE__, size, name: __MODULE__)

  def print(board),     do: GenServer.cast(__MODULE__, {:print, board})

  # external API ^

  def init(size) do
    cols = fetch_cols!

    allocated_cols =
      cols
      |> allocate_cols(size)

    {:ok, size, cols, allocated_cols}
  end

  # helpers v

  defp allocate_cols(cols, size) do
    
  end

  defp fetch_cols!, do: elem(:io.columns, 1)
end
