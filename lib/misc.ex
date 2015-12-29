defmodule Misc do
  alias IO.ANSI

  # defmacro if_else_tap(bool, if_exp, else_exp) do
  #   quote do: if unquote(bool), do: unquote(if_exp), else: unquote(else_exp)
  # end

  defmacro get_config(key), do: quote do: Application.get_env(:tic_tac_toe, unquote(key))

  defmacro wrap_pre(right, left), do: quote do: {unquote(left), unquote(right)}
  defmacro wrap_app(left, right), do: quote do: {unquote(left), unquote(right)}

  defmacro push_in(el, list), do: quote do: [unquote(el) | unquote(list)]

  defmacro cap(str, lcap, rcap),   do: quote do: unquote(lcap) <> unquote(str) <> unquote(rcap)
  defmacro cap(str, {lcap, rcap}), do: quote do: unquote(lcap) <> unquote(str) <> unquote(rcap)
  defmacro cap(str, cap),          do: quote do: unquote(cap)  <> unquote(str) <> unquote(cap)

  defmacro cap_list(list, lcap, rcap),   do: quote do: unquote(lcap) ++ unquote(list) ++ unquote(rcap)
  defmacro cap_list(list, {lcap, rcap}), do: quote do: unquote(lcap) ++ unquote(list) ++ unquote(rcap)
  defmacro cap_list(list, cap),          do: quote do: unquote(cap)  ++ unquote(list) ++ unquote(cap)

  defmacro str_pre(rstr, lstr), do: quote do: unquote(lstr) <> unquote(rstr)
  defmacro str_app(lstr, rstr), do: quote do: unquote(lstr) <> unquote(rstr)

  defmacro cap_reset(str, fun), do: quote do: unquote(str) <> apply(ANSI, unquote(fun), []) <> ANSI.reset

  defmacro dup_str(len, str), do: quote do: String.duplicate(unquote(str), unquote(len))
  defmacro pad(len),          do: quote do: String.duplicate(" ", unquote(len))

  defmacro map_to_tup(col, fun), do: quote do: Enum.map(unquote(col), unquote(fun)) |> List.to_tuple

  defmacro ceil_trunc(float), do: quote do: Float.ceil(quote(float)) |> trunc
  # defmacro apply_wrap_pre(right, left, mod, fun) do
  #   quote do
  #     {apply(unquote(mod), unquote(fun), [unquote(left)]), apply(unquote(mod), unquote(fun), [unquote(right)])}
  #   end
  # end

  # defmacro apply_wrap_app(left, right, mod, fun) do
  #   quote do
  #     {apply(unquote(mod), unquote(fun), [unquote(left)]), apply(unquote(mod), unquote(fun), [unquote(right)])}
  #   end
  # end

  defmacro split_pads(len) do
    quote do
      pad_len = div(len, 2)
      pad_wrap(pad_len, pad_len)
    end
  end

  defmacro ljust_pads(len) do
    quote do
      {lpad_len, rem_len} = div_rem(unquote(len), 2)
      pad_wrap(lpad_len, lpad_len + rem_len)
    end
  end

  defmacro riust_pads(len) do
    quote do
      {rpad_len, rem_len} = div_rem(unquote(len), 2)
      pad_wrap(rpad_len, rpad_len + rem_len)
    end
  end

  def wrap(right, left, :pre), do: {left, right} 
  def wrap(left, right, :app), do: {left, right} 

  def fetch_dims! do
    {:ok, rows} = :io.rows
    {:ok, cols} = :io.columns
    {rows, cols}
  end

  # defmacrop pad(len), do: quote do: dup_str(unquote(len), " ")

  defmacrop div_rem_two(nmr), do: quote do: {div(unquote(nmr), 2), rem(unquote(nmr), 2)} 

  defmacrop pad(len), do: quote do: String.duplicate(" ", unquote(len))

  defmacrop pad_wrap(left, right), do: quote do: {pad(unquote(left)), pad(unquote(right))}

  # defmacrop div_rem(nmr, dvr), do: quote do: {div(unquote(nmr), unquote(dvr)), rem(unquote(nmr), unquote(dvr))}
end
