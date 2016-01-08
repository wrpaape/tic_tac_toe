defmodule Elixir.TicTacToe.Board.InitialState.BoardSize1 do
  def valid_moves do
    ["1"]
  end

  def win_state do
    [["1"]]
    |> Enum.map(&Enum.into(&1, HashSet.new))
  end

  def outcome_counts do
    [1]
  end

  def move_map do
    [row_0: [col_0: "1"]]
  end

  def move_cells do
    %{"1" => {:row_0, :col_0}}
  end
end