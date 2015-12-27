defmodule TicTacToe do
  alias TicTacToe.Board

  def start({next_up, on_deck}) do
    next_up
    |> next_move(on_deck)
    |> game_over
  end

  def next_move(next_up, on_deck) do
    next_up
    |> Board.next_move
    |> case do
      :ok    -> next_move(on_deck, next_up)
      go_msg -> go_msg
    end
  end


  def game_over({winner, winning_moves, num_turns}) do
    
  end

  def game_over(prompt_chunks) do
    prompt_chunks
    |> Enum.each(fn(chunk)->
      chunk
      |> IO.write

      :timer.sleep 250
    end)
  end
end

