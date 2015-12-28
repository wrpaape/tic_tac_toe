defmodule TicTacToe.Board.Printer do
  use GenServer

  require Misc

  def start_link(size), do: GenServer.start_link(__MODULE__, size, name: __MODULE__)

  def print(move, token),     do: GenServer.cast(__MODULE__, {:print, move, token})

  # external API ^

  def init(size) do
    dims = fetch_dims!

    allocated_dims =
      dims
      |> allocate_dims(size)

    {:ok, size, dims, allocated_dims}
  end

  # helpers v


  defp allocate_dims(cols, size) do
    &div(&1 -  1, size)
    next_board =
      board
      |> List.update_at(row_fun.(next_move), fn(row)->
        row
        |> List.keyreplace_at(next_move, 0, {next_move, token})
      end)
    
  end

  # defp fetch_dims!, do: Enum.map(~w(rows columns)a, &elem(apply(:io, dim, []), 1))
  defp fetch_dims! do
    {:ok, rows} = :io.rows
    {:ok, cols} = :io.columns

    {rows, cols}
  end
  


  defp outer_pads(rem_cols) do
    lpad_len = div(rem_cols, 2)
    lpad_len = div(rem_cols, 2)

    {}
  end

end
