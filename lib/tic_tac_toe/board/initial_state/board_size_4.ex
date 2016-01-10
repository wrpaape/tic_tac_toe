defmodule Elixir.TicTacToe.Board.InitialState.BoardSize4 do
  def valid_moves do
    ["1", "2", "3", "4", "q", "w", "e", "r", "a", "s", "d", "f", "z", "x", "c", "v"]
  end

  def win_state do
    [["4", "r", "f", "v"], ["3", "e", "d", "c"], ["2", "w", "s", "x"],
     ["1", "q", "a", "z"], ["1", "2", "3", "4"], ["q", "w", "e", "r"],
     ["a", "s", "d", "f"], ["z", "x", "c", "v"], ["v", "d", "w", "1"],
     ["z", "s", "e", "4"]]
    |> Enum.map(&Enum.into(&1, HashSet.new))
  end

  def move_cells do
    [row_0: [col_0: "1", col_1: "2", col_2: "3", col_3: "4"],
     row_1: [col_0: "q", col_1: "w", col_2: "e", col_3: "r"],
     row_2: [col_0: "a", col_1: "s", col_2: "d", col_3: "f"],
     row_3: [col_0: "z", col_1: "x", col_2: "c", col_3: "v"]]
  end

  def move_map do
    %{"1" => {:row_0, :col_0}, "2" => {:row_0, :col_1}, "3" => {:row_0, :col_2},
      "4" => {:row_0, :col_3}, "a" => {:row_2, :col_0}, "c" => {:row_3, :col_2},
      "d" => {:row_2, :col_2}, "e" => {:row_1, :col_2}, "f" => {:row_2, :col_3},
      "q" => {:row_1, :col_0}, "r" => {:row_1, :col_3}, "s" => {:row_2, :col_1},
      "v" => {:row_3, :col_3}, "w" => {:row_1, :col_1}, "x" => {:row_3, :col_1},
      "z" => {:row_3, :col_0}}
  end
end