defmodule TicTacToe.Helper do
  def wrap_pre(right, left), do: {left, right}
  def wrap_app(left, right), do: {left, right}

  def cap(str, lcap, rcap), do: lcap <> str <> rcap
  def cap(str, cap),        do:  cap <> str <> cap

  def str_pre(rstr, lstr), do: lstr <> rstr
  def str_app(lstr, rstr), do: lstr <> rstr
end
