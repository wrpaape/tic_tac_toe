defmodule Elixir.TicTacToe.Board.InitialState.BoardSize3 do
  def valid_moves do
    ["1", "2", "3", "q", "w", "e", "a", "s", "d"]
  end

  def win_state do
    [["3", "e", "d"], ["2", "w", "s"], ["1", "q", "a"], ["1", "2", "3"],
     ["q", "w", "e"], ["a", "s", "d"], ["d", "w", "1"], ["a", "w", "3"]]
    |> Enum.map(&Enum.into(&1, HashSet.new))
  end

  def move_cells do
    [row_0: [col_0: "1", col_1: "2", col_2: "3"],
     row_1: [col_0: "q", col_1: "w", col_2: "e"],
     row_2: [col_0: "a", col_1: "s", col_2: "d"]]
  end

  def move_map do
    %{"1" => {:row_0, :col_0}, "2" => {:row_0, :col_1}, "3" => {:row_0, :col_2},
      "a" => {:row_2, :col_0}, "d" => {:row_2, :col_2}, "e" => {:row_1, :col_2},
      "q" => {:row_1, :col_0}, "s" => {:row_2, :col_1}, "w" => {:row_1, :col_1}}
  end
end