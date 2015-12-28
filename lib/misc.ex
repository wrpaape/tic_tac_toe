defmodule Misc do
  alias IO.ANSI

  # defmacro if_else_tap(bool, if_exp, else_exp) do
  #   quote do: if unquote(bool), do: unquote(if_exp), else: unquote(else_exp)
  # end

  defmacro get_config(key), do: quote do: Application.get_env(:tic_tac_toe, unquote(key))

  defmacro wrap_pre(right, left), do: quote do: {unquote(left), unquote(right)}
  defmacro wrap_app(left, right), do: quote do: {unquote(left), unquote(right)}

  defmacro push_in(el, list), do: quote do: [unquote(el) | unquote(list)]

  defmacro cap(str, lcap, rcap), do: quote do: unquote(lcap) <> unquote(str) <> unquote(rcap)
  defmacro cap(str, cap),        do: quote do: unquote(cap)  <> unquote(str) <> unquote(cap)
  
  defmacro str_pre(rstr, lstr), do: quote do: unquote(lstr) <> unquote(rstr)
  defmacro str_app(lstr, rstr), do: quote do: unquote(lstr) <> unquote(rstr)

  defmacro cap_reset(str, ansi_fun), do: quote do: unquote(str) <> apply(ANSI, unquote(ansi_fun), []) <> ANSI.reset

  def wrap(right, left, :pre), do: {left, right} 
  def wrap(left, right, :app), do: {left, right} 
end
