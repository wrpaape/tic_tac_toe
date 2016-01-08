defmodule TicTacToe do
  alias IO.ANSI
  alias TicTacToe.{Board, Computer, Player}

  @colors      ~w(red yellow green blue cyan magenta)a
  @intensities ~w(bright normal faint normal)a

  def start(turn_tup = {next_up, on_deck}) do
    turn_tup
    |> case  do
      {{Computer, {_, comp}}, {Player, {_, player}}}   ->
        [{comp, player}]

      {{Player, {_, player}}, {Computer, {_, comp}}}   ->
        [{comp, player}]

      {{Computer, {_, comp1}}, {Computer, {_, comp2}}} ->
        [{comp1, comp2}, {comp2, comp1}]

      _ -> []
    end
    |> Enum.each(&Computer.start_link/1)

    next_up
    |> next_move(on_deck)
    |> game_over
  end

  # external api ^

  defp next_move(next_up, on_deck) do
    next_up
    |> Board.next_move
    |> case do
      :cont  -> next_move(on_deck, next_up)
      :tie   -> fun_prompt("C A T ' S   G A M E")
      :win   -> next_up
    end
  end

  defp game_over({Computer, token}), do: winner_prompt("C O M P U T E R ", token)
  defp game_over({Player, token}),   do: winner_prompt("P L A Y E R ", token)

  defp winner_prompt(player, {color, char}) do
    [fun_prompt(player), color <> char <> ANSI.reset, fun_prompt(" W I N S !")]
    |> game_over
  end

  defp game_over(go_msg) do
    go_msg
    |> Enum.each(fn(chunk)->
      chunk
      |> IO.write

      :timer.sleep 250
    end)
  end

  # helpers v

  defp fun_prompt(prompt) do
    @colors
    |> ansi_cycle
    |> Stream.zip(ansi_cycle(@intensities))
    |> Enum.reduce_while({[], blink_chunks(prompt)}, fn
      (_fun_tup, {final_rev_chars, []})->
        final_rev_chars
        |> Utils.wrap_pre(:halt)

      ({color, int}, {rev_chars, [next_char | rem_chars]})->
        [Utils.cap(color, int, next_char) | rev_chars]
        |> Utils.wrap_app(rem_chars)
        |> Utils.wrap_pre(:cont)
    end)
  end

  defp blink_chunks(str) do
    [first_char | rem_chars] =
      str
      |> String.graphemes

    rem_chars
    |> Enum.reduce([ANSI.blink_slow <> first_char], fn
      (char, rem_chunks)->
        char
        |> String.match?(~r/\s/)
        |> if do
          rem_chunks
          |> List.update_at(0, &(&1 <> char))
        else
          [char | rem_chunks]
        end
    end)
    |> List.update_at(0, &(&1 <> ANSI.reset))
  end

  defp ansi_cycle(ansi_funs) do
    ansi_funs
    |> Enum.map(&apply(ANSI, &1, []))
    |> Stream.cycle
  end
end

