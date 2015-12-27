defmodule TicTacToe.Helper do
  alias IO.ANSI

  @colors      ~w(red yellow green blue cyan magenta)a
  @intensities ~w(bright normal faint normal)a

  def get_config(key), do: Application.get_env(:tic_tac_toe, key)

  def wrap_pre(right, left), do: {left, right}
  def wrap_app(left, right), do: {left, right}

  def cap(str, lcap, rcap), do: lcap <> str <> rcap
  def cap(str, cap),        do:  cap <> str <> cap
  
  def cap_reset(str, ansi_fun), do: cap(str, apply(ANSI, ansi_fun, []), ANSI.reset)

  def str_pre(rstr, lstr), do: lstr <> rstr
  def str_app(lstr, rstr), do: lstr <> rstr

  def fun_prompt(prompt) do
    @colors
    |> ansi_cycle
    |> Stream.zip(ansi_cycle(@intensities))
    |> Enum.reduce_while({[], String.graphemes(prompt)}, fn
      (_fun_tup, {final_rev_chars, []})->
        final_rev_chars
        |> List.update_at(0, &(&1 <> ANSI.reset))
        |> Enum.reverse
        |> List.update_at(0, &(ANSI.blink_slow <> &1))
        |> wrap_pre(:halt)

      ({color, int}, {rev_chars, [next_char | rem_chars]})->
        [cap(color, int, next_char) | rev_chars]
        |> wrap_app(rem_chars)
        |> wrap_pre(:cont)
        
    end)
  end

  def ansi_cycle(ansi_funs) do
    ansi_funs
    |> Enum.map(&apply(ANSI, &1, []))
    |> Stream.cycle
  end
end
