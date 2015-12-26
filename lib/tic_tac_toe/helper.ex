defmodule TicTacToe.Helper do
  alias IO.ANSI

  def get_config(key), do: Application.get_env(:tic_tac_toe, key)

  def wrap_pre(right, left), do: {left, right}
  def wrap_app(left, right), do: {left, right}

  def cap(str, lcap, rcap), do: lcap <> str <> rcap
  def cap(str, cap),        do:  cap <> str <> cap
  
  def cap_reset(str, ansi_fun), do: cap(str, apply(ANSI, ansi_fun, []), ANSI.reset)

  def str_pre(rstr, lstr), do: lstr <> rstr
  def str_app(lstr, rstr), do: lstr <> rstr
end
