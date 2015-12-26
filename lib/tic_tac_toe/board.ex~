defmodule TicTacToe.Board do
  use GenServer

  alias TicTacToe.Helper

  def start_link(board_size), do: GenServer.start_link(__MODULE__, board_size, name: __MODULE__)

  def add_tokens(tokens), do: GenServer.cast(__MODULE__, tokens, name: __MODULE__)

  def state,                  do: GenServer.call(__MODULE__, :state)

  # external API ^
  
  def init(board_size) do
    open_moves =
      board_size
      |> :math.pow(2)
      |> trunc
      |> Range.new(1)
      |> Enum.reduce([], fn(pos, moves)->
       [Integer.to_string(pos) | moves] 
      end)

    winning_moves =
      open_moves
      |> Enum.chunk(board_size)
      |> calculate_winning_moves

    board =
      open_moves
      |> Enum.map(&{&1, &1})
      
    {board, Enum.into(open_moves, HashSet.new), winning_moves}
    |> Helper.wrap_pre(:ok)
  end

  # def handle_cast({:add_tokens, tokens}, state) do
  #   tokens  
  #   |> Stream.cycle
  #   |> 
  # end

  def handle_call(:state, _from, board) do
    board
    |> IO.inspect
    |> Tuple.duplicate(2)
    |> Tuple.insert_at(0, :reply)
  end

  # helpers v

  def calculate_winning_moves(row_chunks) do
    rows =
      row_chunks
      |> Enum.reduce(HashSet.new, fn(chunk, rows)->
        rows
        |> Set.put(Enum.into(chunk, HashSet.new))
      end)
      
    rows_cols =
      row_chunks
      |> List.zip
      |> Enum.reduce(rows, fn(chunk_tup, rows_cols)->
        next_cols =
          chunk_tup 
          |> Tuple.to_list
          |> IO.inspect
          |> Enum.into(HashSet.new)

        rows_cols
        |> Set.put(next_cols)
      end)

    row_chunks
    |> Enum.reduce([{HashSet.new, 0, 1}, {HashSet.new, -1, -1}], fn(chunk, diag_tups)->
      diag_tups
      |> Enum.map(fn({diag, at, inc})->
        diag
        |> Set.put(Enum.at(chunk, at)) 
        |> Helper.wrap_app(at + inc)
        |> Tuple.append(inc)
      end)
    end)
    |> Enum.reduce(rows_cols, fn({diag, _, _}, winning_moves)->
      winning_moves
      |> Set.put(diag)
    end)
  end
end

