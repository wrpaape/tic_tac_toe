defmodule TicTacToe do
  alias IO.ANSI
  alias TicTacToe.Board
  alias TicTacToe.Computer
  alias TicTacToe.Player

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
      go_msg -> go_msg
    end
  end

  defp game_over(go_msg) do
    go_msg
    |> fun_prompt
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

