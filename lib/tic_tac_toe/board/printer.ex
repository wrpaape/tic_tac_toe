defmodule TicTacToe.Board.Printer do
  use GenServer

  require Misc

  def start_link(size), do: GenServer.start_link(__MODULE__, size, name: __MODULE__)

  def print(move, token),     do: GenServer.cast(__MODULE__, {:print, move, token})

  # external API ^

  def init(board, size) do
    key_dims = fetch_key_dims!

    cell_dims =
      key_dims
      |> calc_cell_dims(size)

    rows_map = 
      board
      |> build_rows_map(cell_dims)

    statics =
      key_dims
      |> build_statics
      
    {:ok, size, dims, allocated_dims}
  end

  # helpers v

  defp fetch_key_dims! do
    {rows, cols} = Misc.fetch_dims!

    {max(rows, cols), cols}
  end

  defp cell_dims({rows, cols}, size) do
    res =
      rows
      |> max(cols)
      
  end

  defp build_cell do
    
  end

  defp build_row(cells) do
    
  end

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
  
  defp outer_pads(rem_cols) do
    lpad_len = div(rem_cols, 2)
    lpad_len = div(rem_cols, 2)

    {}
  end

end
