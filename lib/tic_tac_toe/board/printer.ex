defmodule TicTacToe.Board.Printer do
  use GenServer

  require Misc
  require BoxChars
  
  @token_space_ratio Helper.get_config(:token_space_ratio)
  @border_thickness  Helper.get_config(:border_thickness)
  @line    BoxChars.get(@border_thickness, :line)
  @caps    BoxChars.get(@border_thickness, :caps)
  @joiners BoxChars.get(@border_thickness, :joiners)

  def start_link(board_tup),   do: GenServer.start_link(__MODULE__, board_tup, name: __MODULE__)

  def print(move, token), do: GenServer.cast(__MODULE__, {:print, move, token})

  # external API ^

  def init({board_state, board_size}) do
    key_dims = {board_res, _outer_pad_len} = fetch_key_dims!

    cell_res =
      board_res
      |> calc_cell_res(board_size)

    find_row = fn(move)->
      move
      |> - 1
      |> div(board_size)
    end

    borders_tup =
      key_dims
      |> build_static_pieces
 
    cell_builder =
      board_res
      |> build_cell_buider_fun(board_size)

    rows_map = 
      board
      |> build_rows_map(cell_builder)
     
    {:ok, board_size, key_dims, find_row, borders_tup, cell_builder, rows_map}
  end

  # helpers v

  defp fetch_key_dims! do
    {rows, cols} = Misc.fetch_dims!
    board_res = min(rows, cols)

    {cols - board_res, board_res}
  end

  defp calc_cell_res(board_res, board_size) do
    board_res
    |> div(board_size)
    |> - (board_size + 1)
  end

  defp build_cell_builder_fun(cell_res, board_size) do
    cell_pad_len = 
      cell_res
      |> div(@token_space_ratio)

    token_space = ceil_res - cell_pad_len * 2

    lr_pad =
      cell_pad_len
      |> Misc.pad

    tb_pad =
      ceil_res
      |> Misc.pad
      |> List.duplicate(pad_len)

    fn(token)->
      token
      |> String.duplicate(token_space)
      |> List.duplicate(token_space)
      |> Enum.map(&Misc.cap(&1, lr_pad))
      |> Misc.cap_list(tb_pad)
    end
  end

  defp build_pads_tup(pad_len), do: Misc.ljust_pads(pad_len)

  defp build_lines_tup(board_res) do
    horiz_line = String.duplicate(, board_res)
    Misc.map_to_tup(@line_caps, &Misc.cap(horiz_line, &1))
  end

  defp build_static_pieces({outer_pad_len, board_res}) do
    {build_pads_tup(pad_len), build_lines_tup(board_res)}
  end

  # defp allocate_dims(cols, board_size) do
  #   &div(&1 -  1, board_size)
  #   next_board =
  #     board
  #     |> List.update_at(row_fun.(next_move), fn(row)->
  #       row
  #       |> List.keyreplace_at(next_move, 0, {next_move, token})
  #     end)
    
  # end
end
