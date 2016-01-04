defmodule TicTacToe.Board.Printer do
  use GenServer

  require Misc
  # ┌──┬──┐   ┏━━┳━━┓   ╔══╦══╗ 
  # │  │  │   ┃  ┃  ┃   ║  ║  ║ 
  # ├──┼──┤   ┣━━╋━━┫   ╠══╬══╣ 
  # │  │  │   ┃  ┃  ┃   ║  ║  ║ 
  # └──┴──┘   ┗━━┻━━┛   ╚══╩══╝ 

  @token_space_ratio 8

  def start_link(board_tup), do: GenServer.start_link(__MODULE__, board_tup, name: __MODULE__)
  
  def state, do: GenServer.call(__MODULE__, :state)

  # def print(move, token),    do: GenServer.cast(__MODULE__, {:print, move, token})

  # external API ^

  def init({move_map, move_cells, board_size}) do
    key_dims = {board_res, outer_pad_len} = fetch_key_dims!

    cell_res =
      board_size
      |> calc_cell_res(board_res)

    statics =
      {_lines, row_caps} =
        board_size
        |> build_static_pieces(cell_res, outer_pad_len)
 
    cell_builder =
      board_size
      |> build_cell_builder_fun(cell_res)

    board = 
      move_cells
      |> build_board(board_size, cell_builder, row_caps, cell_res)

     
    {:ok, {board_size, key_dims, move_map, statics, cell_builder, board}}
  end

  def handle_call(:state, _from, state), do: {:reply, state, state}


  # helpers v

  defp build_board(move_cells, board_size, cell_builder, row_caps, cell_res) do
    move_cells
    |> Enum.map(fn({row_key, row}) ->
      {cells_kw, cells} =
        row
        |> Enum.map_reduce([], fn({col_key, cell_move}, acc_cells)->
          cell = cell_builder.(cell_move)
          {{col_key, cell}, [cell | acc_cells]}
        end)
      
      {row_key, {board_size, cells_kw, build_row(cell_res, cells, row_caps, "")}}
    end)
  end

  defp build_row(0, _, _, acc_row), do: acc_row

  defp build_row(rem_cell_rows, cells, caps = {lcap, _rcap}, acc_row) do
    {next_cells, cell_row} =
      cells
      |> Enum.map_reduce(lcap, fn([next_cell_row | rem_cell_rows], acc_cell_row)->
       {rem_cell_rows, acc_cell_row <> next_cell_row <> "║"}
      end)

    build_row(rem_cell_rows - 1, next_cells, caps, acc_row <> cell_row <> "\n")
  end

  defp fetch_key_dims! do
    {rows, cols} = Misc.fetch_dims!
    board_res = min(rows, cols)

    {board_res, cols - board_res}
  end

  defp calc_cell_res(board_size, board_res) do
    board_res
    |> div(board_size)
    |> - (board_size + 1)
  end

  defp build_cell_builder_fun(board_size, cell_res) do
    cell_pad_len = 
      cell_res
      |> div(@token_space_ratio)

    token_space = cell_res - cell_pad_len * 2

    lr_pad =
      cell_pad_len
      |> Misc.pad

    tb_pad =
      cell_res
      |> Misc.pad
      |> List.duplicate(cell_pad_len)

    fn(token)->
        token
        |> String.duplicate(token_space)
        |> List.duplicate(token_space)
        |> Enum.map(&Misc.cap(&1, lr_pad))
        |> Misc.cap_list(tb_pad)
    end
  end

  defp build_pads_tup(pad_len), do: Misc.ljust_pads(pad_len)

  defp build_lines(horiz_lines, num_mids, pads_tup) do
    [{1, "╦", {"╔", "╗"}}, {num_mids, "╬", {"╠", "╣"}}, {1, "╩", {"╚", "╝"}}]
    |> Enum.flat_map(fn({num_lines, join, caps})->
      horiz_lines
      |> Enum.join(join)
      |> Misc.cap(caps)
      |> Misc.cap(pads_tup)
      |> List.duplicate(num_lines)
    end)
  end

  defp build_static_pieces(board_size, cell_res, pad_len) do
    pads_tup =
      {lpad, rpad} =
        pad_len
        |> build_pads_tup
    
    "═"
    |> String.duplicate(cell_res)
    |> List.duplicate(board_size)
    |> build_lines(board_size - 1, pads_tup)
    |> Misc.wrap_app({lpad <> "║", rpad})
  end
  # ┌──┬──┐   ┏━━┳━━┓   ╔══╦══╗ 
  # │  │  │   ┃  ┃  ┃   ║  ║  ║ 
  # ├──┼──┤   ┣━━╋━━┫   ╠══╬══╣ 
  # │  │  │   ┃  ┃  ┃   ║  ║  ║ 
  # └──┴──┘   ┗━━┻━━┛   ╚══╩══╝ 

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
