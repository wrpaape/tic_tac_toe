defmodule TicTacToe.Helper do
  alias IO.ANSI

  @colors      ~w(red yellow green blue cyan magenta)a
  @intensities ~w(bright normal faint normal)a

  defmacro if_else_tap(bool, if_exp, else_exp) do
    quote do: if unquote(bool), do: unquote(if_exp), else: unquote(else_exp)
  end

  def get_config(key), do: Application.get_env(:tic_tac_toe, key)

  def wrap_pre(right, left), do: {left, right}
  def wrap_app(left, right), do: {left, right}
  def wrap(right, left, :p), do: {left, right}
  def wrap(left, right, :a), do: {left, right}

  def push_in(el, list), do: [el | list]

  def cap(str, lcap, rcap), do: lcap <> str <> rcap
  def cap(str, cap),        do:  cap <> str <> cap
  
  def cap_reset(str, ansi_fun), do: cap(str, apply(ANSI, ansi_fun, []), ANSI.reset)

  def str_pre(rstr, lstr), do: lstr <> rstr
  def str_app(lstr, rstr), do: lstr <> rstr

  def fun_prompt(prompt) do
    @colors
    |> ansi_cycle
    |> Stream.zip(ansi_cycle(@intensities))
    |> Enum.reduce_while({[], blink_chunks(prompt)}, fn
      (_fun_tup, {final_rev_chars, []})->
        final_rev_chars
        |> wrap_pre(:halt)

      ({color, int}, {rev_chars, [next_char | rem_chars]})->
        [cap(color, int, next_char) | rev_chars]
        |> wrap_app(rem_chars)
        |> wrap_pre(:cont)
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
