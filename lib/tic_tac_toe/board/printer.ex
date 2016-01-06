defmodule TicTacToe.Board.Printer do
  use GenServer

  alias IO.ANSI

  # ┌──┬──┐   ┏━━┳━━┓   ╔══╦══╗ 
  # │  │  │   ┃  ┃  ┃   ║  ║  ║ 
  # ├──┼──┤   ┣━━╋━━┫   ╠══╬══╣ 
  # │  │  │   ┃  ┃  ┃   ║  ║  ║ 
  # └──┴──┘   ┗━━┻━━┛   ╚══╩══╝ 

  @board_tot_ratio 0.75
  @token_pad_ratio 8

  @board_fg  ANSI.normal <> ANSI.white_background <> ANSI.black
  @board_bg  ANSI.black_background
  @cell_join @board_fg <> "║"

  def start_link(board_tup), do: GenServer.start_link(__MODULE__, board_tup, name: __MODULE__)
  
  def state, do: GenServer.call(__MODULE__, :state)

  def update(move, token), do: GenServer.cast(__MODULE__, {:update, move, token})

  def print,               do: GenServer.call(__MODULE__, :print)

  def reject_pattern do
    ~w(? no_ home not_ font off clear default normal reset)
    |> :binary.compile_pattern
  end

  def ansi_test do
    :functions
    |> ANSI.__info__
    |> Enum.filter_map(&(elem(&1, 1) == 0), &to_string(elem(&1, 0)))
    |> Enum.filter_map(&not(String.contains?(&1, reject_pattern)), &{String.to_atom(&1), &1})
    |> Enum.sort
    |> Enum.reduce(ANSI.clear, fn({fun, str}, acc)->
      acc <> apply(ANSI, fun, []) <> "\ntesting IO.ANSI." <> str <> ANSI.reset
    end)
    |> IO.write
  end

  # external API ^

  def init({move_map, move_cells, board_size}) do
    {rows, cols} = Utils.fetch_dims!

    {res_x, res_y, pad_len} =
      board_size
      |> cell_res_and_outer_pad_len(rows, cols)

    {lines, row_caps} =
      board_size
      |> build_static_pieces(res_x, pad_len)
 
    cell_builder =
      board_size
      |> build_cell_builder_fun(res_x, res_y)

    board = 
      move_cells
      |> build_board(cell_builder, row_caps)

    {:ok, {{board, lines}, board_size, move_map, rows, cols, row_caps, cell_builder}}
  end

  def handle_call(:state, _from, state), do: {:reply, state, state}

  def handle_call(:print, _from, state) do
    {:reply, state |> elem(0) |> print, state}
  end

  def handle_cast({:update, move, token}, {{board, lines}, b_size, moves, rows, cols, caps, c_fun}) do
    next_board = 
      Utils.fetch_dims!
      |> case do
        {^rows, ^cols} ->
            board
            |> update_board(moves[move], c_fun.(token), caps)

            # need new cell builder, rows
        # {rows, ^cols} ->


          # need new cell builder, lines, cols
        # {^rows, cols} ->


          # need new cell builder, lines, row, cols
        # {rows, cols} ->

      end

    {:noreply, {{next_board, lines}, b_size, moves, rows, cols, caps, c_fun}}
  end

  # helpers v

  defp print({board, {mid, top_bot}}) do
    board
    |> Enum.map_join(mid, fn({_, {_, row}})->
      row
    end)
    |> Utils.cap(top_bot)
  end

  defp update_board(board, {row, col}, cell, caps) do
    board
    |> Keyword.update!(row, &update_row(&1, col, cell, caps))
  end

  defp update_row({cells, _row}, col, cell, caps) do
    {next_cells, next_cell_vals} =
      cells
      |> update_and_unzip(col, cell, Keyword.new, [])

    {next_cells, print_row(next_cell_vals, caps, "")}
  end

  defp update_and_unzip([{col, _} | rem_cells], col, cell, acc_cells, acc_vals) do
    rem_vals =
      rem_cells
      |> Keyword.values

    [{col, cell} | acc_cells]
    |> Enum.reverse(rem_cells)
    |> Utils.wrap_app(Enum.reverse([cell | acc_vals], rem_vals))
  end

  defp update_and_unzip([tup = {_, val} | rem_cells], col, cell, acc_cells, acc_vals) do
    rem_cells
    |> update_and_unzip(col, cell, [tup | acc_cells], [val | acc_vals])
  end

  defp build_board(move_cells, cell_builder, row_caps) do
    move_cells
    |> Enum.map(fn({row_key, row}) ->
      {cells, cell_vals} =
        fn({col_key, cell_move}, acc_cells)->
          cell = cell_builder.({ANSI.faint, cell_move})

          {{col_key, cell}, [cell | acc_cells]}
        end
        |> :lists.mapfoldr([], row)
      
      {row_key, {cells, print_row(cell_vals, row_caps, "")}}
    end)
  end

  defp print_row([[] | _], _, acc_row),               do: acc_row
  defp print_row(cells, caps = {lcap, rcap}, acc_row) do
    {next_cells, cell_row} =
      cells
      |> Enum.map_reduce(lcap, fn([next_cell_row | rem_cell_rows], acc_cell_row)->
       {rem_cell_rows, acc_cell_row <> next_cell_row <> @cell_join}
      end)

    next_cells
    |> print_row(caps, acc_row <> cell_row <> rcap)
  end

  defp cell_res(dim, board_size) do
    dim * @board_tot_ratio
    |> trunc
    |> - (board_size + 1)
    |> div(board_size)
  end

  defp cell_res_and_outer_pad_len(board_size, rows, cols) do
    res_x = cell_res(cols, board_size)
    res_y = cell_res(rows, board_size)

    {res_x, res_y, cols - (res_x + 1) * board_size - 1}
  end

  defp build_cell_builder_fun(board_size, res_x, res_y) do
    lr_pad_len = div(res_x, @token_pad_ratio)

    token_space_x = res_x - lr_pad_len * 2

    lr_pad = Utils.pad(lr_pad_len)

    tb_pad_len = div(res_y, @token_pad_ratio)

    token_space_y = res_y - tb_pad_len * 2

    tb_pad =
      res_x
      |> Utils.pad
      |> List.duplicate(tb_pad_len)

    fn({color, char})->
      char
      |> String.duplicate(token_space_x)
      |> Utils.cap(color, @board_fg)
      |> List.duplicate(token_space_y)
      |> Enum.map(&Utils.cap(&1, lr_pad))
      |> Utils.cap_list(tb_pad)
    end
  end

  defp build_lines(horiz_lines, pads_tup) do
    [top, mid, bot] =
      [{"╦", {"╔", "╗"}}, {"╬", {"╠", "╣"}}, {"╩", {"╚", "╝"}}]
      |> Enum.map(fn({join, caps})->
        horiz_lines
        |> Enum.join(join)
        |> Utils.cap(caps)
        |> Utils.cap(@board_fg, @board_bg)
        |> Utils.cap(pads_tup)
      end)

    {mid, {ANSI.clear <> top, bot <> ANSI.reset}}
  end

  defp build_static_pieces(board_size, res_x, pad_len) do
    pads_tup =
      {lpad, rpad} =
        pad_len
        |> Utils.ljust_pads
    
    "═"
    |> String.duplicate(res_x)
    |> List.duplicate(board_size)
    |> build_lines(pads_tup)
    |> Utils.wrap_app({lpad <> @cell_join , @board_bg <> rpad})
  end
  # ┌──┬──┐   ┏━━┳━━┓   ╔══╦══╗ 
  # │  │  │   ┃  ┃  ┃   ║  ║  ║ 
  # ├──┼──┤   ┣━━╋━━┫   ╠══╬══╣ 
  # │  │  │   ┃  ┃  ┃   ║  ║  ║ 
  # └──┴──┘   ┗━━┻━━┛   ╚══╩══╝ 
end
