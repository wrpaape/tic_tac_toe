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

  def init({board_state, board_size}) do
    key_dims = {board_res, outer_pad_len} = fetch_key_dims!

    cell_res =
      board_size
      |> calc_cell_res(board_res)

    find_row = fn(move)->
      move
      |> - 1
      |> div(board_size)
    end

    lines_pads_tup =
      board_size
      |> build_static_pieces(cell_res, outer_pad_len)
 
    cell_builder =
      board_size
      |> build_cell_builder_fun(cell_res)

    # rows_map = 
    #   board_state
    #   |> build_rows_map(cell_builder)
     
    {:ok, {board_size, key_dims, find_row, lines_pads_tup, cell_builder, []}}
  end

  def handle_call(:state, _from, state), do: {:reply, state, state}

  # helpers v

  defp fetch_key_dims! do
    {rows, cols} = Misc.fetch_dims!
    board_res = min(rows, cols)

    {cols - board_res, board_res}
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
      pad_len
      |> build_pads_tup
    
    "═"
    |> String.duplicate(cell_res)
    |> List.duplicate(board_size)
    |> build_lines(board_size - 1, pads_tup)
    |> Misc.wrap_app(pads_tup)
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
