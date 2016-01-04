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

  def print(move, token), do: GenServer.cast(__MODULE__, {:print, move, token})

  # external API ^

  def init({move_map, move_cells, board_size}) do
    key_dims =
      {board_res, cols} =
        fetch_key_dims!

    cell_pad =
      {cell_res, _outer_pad_len} =
        board_size
        |> cell_res_and_outer_pad_len(key_dims)

    {lines, row_caps} =
      board_size
      |> build_static_pieces(cell_pad)
 
    cell_builder =
      board_size
      |> build_cell_builder_fun(cell_res)

    board = 
      move_cells
      |> build_board(board_size, cell_builder, row_caps)

    # dims = Map.new
    #   |> Map.put(:b_size, board_size)
    #   |> Map.put(:b_res,  board_res)
    #   |> Map.put(:cols,   cols)
    #   |> Map.put(:c_res,  cell_res)
    #   |> Map.put(:p_len,  outer_pad_len)

    # {:ok, {board_size, move_map, key_dims, lines_caps, cell_builder, board}}
    {:ok, {board_size, move_map, board_res, cols, lines, row_caps, cell_builder, board}}


    # {:ok, {dims, statics, cell_builder, board, move_map}}
  end

  def handle_call(:state, _from, state), do: {:reply, state, state}

  def handle_cast({:print, move, token}, {b_size, moves, b_res, cols, lines, caps, c_fun, board}) do
    # fetch_key_dims!
    # |> case do
    #   {^dims.b_res, ^dims.cols} ->
    #     board
    #     |> update_board(moves[move], c_fun.(token))

    #   {b_res, ^dims.cols} ->


    #   {^dims.b_res, cols} ->


    #   {b_res, cols} ->

    # end

    {:noreply, nil}
  end

  # helpers v

  defp update_board(board, {row, col}, cell), do: Keyword.update!(board, row, &update_row(&1, col, cell))

  defp update_row({free_cells, cells, _row}) do
  end

  defp build_board(move_cells, board_size, cell_builder, row_caps) do
    move_cells
    |> Enum.map(fn({row_key, row}) ->
      {cells_kw, cells} =
        row
        |> Enum.map_reduce([], fn({col_key, cell_move}, acc_cells)->
          cell = cell_builder.(cell_move)
          {{col_key, cell}, [cell | acc_cells]}
        end)
      
      {row_key, {board_size, cells_kw, build_row(cells, row_caps, "")}}
    end)
  end

  defp build_row([[] | _], _, acc_row),               do: acc_row
  defp build_row(cells, caps = {lcap, rcap}, acc_row) do
    {next_cells, cell_row} =
      cells
      |> Enum.map_reduce(lcap, fn([next_cell_row | rem_cell_rows], acc_cell_row)->
       {rem_cell_rows, acc_cell_row <> next_cell_row <> "║"}
      end)

    next_cells
    |> build_row(caps, acc_row <> cell_row <> rcap)
  end

  defp fetch_key_dims! do
    {rows, cols} = Misc.fetch_dims!

    {min(rows, cols), cols}
  end

  defp cell_res_and_outer_pad_len(board_size, {board_res, cols}) do
    cell_res =
      board_res
      |> - (board_size + 1)
      |> div(board_size)

    {cell_res, cols - (cell_res + 1) * board_size - 1}
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

  defp build_lines(horiz_lines, pads_tup) do
    [top, mid, bot] =
      [{"╦", {"╔", "╗"}}, {"╬", {"╠", "╣"}}, {"╩", {"╚", "╝"}}]
      |> Enum.map(fn({join, caps})->
        horiz_lines
        |> Enum.join(join)
        |> Misc.cap(caps)
        |> Misc.cap(pads_tup)
      end)

    {mid, {top, bot}}
  end

  defp build_static_pieces(board_size, {cell_res, pad_len}) do
    pads_tup =
      {lpad, rpad} =
        pad_len
        |> build_pads_tup
    
    "═"
    |> String.duplicate(cell_res)
    |> List.duplicate(board_size)
    |> build_lines(pads_tup)
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
