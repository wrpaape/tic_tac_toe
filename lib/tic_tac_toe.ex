defmodule TicTacToe do
  alias IO.ANSI
  alias TicTacToe.Helper
  alias TicTacToe.Board

  @warning "invalid move, please select from:\n  "
    |> Helper.cap(ANSI.red, ANSI.bright <> ANSI.yellow)

  def start(tokens) do
    tokens
    |> Stream.cycle
    |> Enum.reduce_while(1, fn(player_tup, turn)->
      player_tup
      |> next_move(turn + 1)
    end)
    |> game_over

    System.halt(0)
  end

  def next_move(player_tup = {module, token}, next_turn) do
    module.next_move
    |> Board.move_token(token)
    |> case do
      :ok           -> {:cont, next_turn} 
      :tie          -> {:halt, "cat's game"}
      {:win, moves} -> {:halt, {token, moves, next_turn}}
      {:invalid, valid_moves} -> 
        valid_moves
        |> inspect
        |> Helper.cap(@warning, ANSI.reset)
        |> IO.puts

        player_tup
        |> next_move(next_turn)
    end
  end


  def game_over({winner, winning_moves, num_turns}) do
    
  end

  def game_over(tie_prompt) do
    tie_prompt
    |> Helper.fun_prompt
    |> Enum.each(fn(fun_char)->
      fun_char
      |> IO.write

      :timer.sleep 250
    end)
  end
end

