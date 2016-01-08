defmodule Elixir.TicTacToe.Board.InitialState.BoardSize2 do
  def valid_moves do
    ["1", "2", "q", "w"]
  end

  def win_state do
    [["2", "w"], ["1", "q"], ["1", "2"], ["q", "w"], ["w", "1"], ["q", "2"]]
    |> Enum.map(&Enum.into(&1, HashSet.new))
  end

  def outcome_counts do
    [0, 0, 24]
  end

  def move_map do
    [row_0: [col_0: "1", col_1: "2"], row_1: [col_0: "q", col_1: "w"]]
  end

  def move_cells do
    %{"1" => {:row_0, :col_0}, "2" => {:row_0, :col_1}, "q" => {:row_1, :col_0},
      "w" => {:row_1, :col_1}}
  end
end