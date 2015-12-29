defmodule TicTacToe.Board.Printer do
  use GenServer

  require Misc
  
  @box_chars Misc.box_chars(:thick)

  def start_link(size),   do: GenServer.start_link(__MODULE__, size, name: __MODULE__)

  def print(move, token), do: GenServer.cast(__MODULE__, {:print, move, token})

  # external API ^

  def init(board, size) do
    key_dims = {board_res, _outer_pad_len} = fetch_key_dims!

    borders_tup =
      key_dims
      |> build_static_pieces
 
    cell_builder =
      board_res
      |> build_cell_buider_fun(size)

    rows_map = 
      board
      |> build_rows_map(cell_builder)
     
    {:ok, size, key_dims, borders_tup, cell_builder, rows_map}
  end

  # helpers v

  defp fetch_key_dims! do
    {rows, cols} = Misc.fetch_dims!
    board_res = max(rows, cols)

    {cols - board_res, board_res}
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

  defp build_pads_tup(pad_len), do: Misc.ljust_pads(pad_len)

  defp build_lines_tup(board_res) do
    # horiz_line = Misc.dup_str(board_res, "─")
    horiz_line = String.duplicate(, board_res)
    Misc.map_to_tup(@line_caps, &Misc.cap(horiz_line, &1))
  end

  defp build_static_pieces({outer_pad_len, board_res}) do
    {build_pads_tup(pad_len), build_lines_tup(board_res)}
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
