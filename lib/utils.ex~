defmodule Utils do
  alias IO.ANSI

  defmacro module_path do
    quote do
      __MODULE__
      |> Mix.Utils.underscore
      |> Path.expand(unquote(project_parent_dir))
    end
  end

  def project_parent_dir do
    ".."
    |> List.duplicate(5)
    |> Path.join
    |> Path.expand(Mix.Project.app_path)
  end

  def get_config(key) do
    Mix.Project.get
    |> Module.split
    |> hd
    |> Mix.Utils.underscore
    |> String.to_atom
    |> Application.get_env(key)
  end

  def wrap_pre(right, left), do: {left, right}
  def wrap_app(left, right), do: {left, right}

  def push_in(el, list), do: [el | list]

  def str_pre(rstr, lstr), do: lstr <> rstr
  def str_app(lstr, rstr), do: lstr <> rstr

  def cap_reset(str, fun), do: apply(ANSI, fun, []) <> str <> ANSI.reset

  def dup_str(len, str), do: String.duplicate(str, len)
  def pad(len),          do: String.duplicate(" ", len)

  def map_to_tup(col, fun), do: col |> Enum.map(fun) |> List.to_tuple

  def ceil_trunc(float), do: Float.ceil(float) |> trunc

  def div_rem_two(nmr),      do: {div(nmr, 2), rem(nmr, 2)} 
  def pad_wrap(left, right), do: {pad(left), pad(right)}

  def cap(str, lcap, rcap),   do: lcap <> str <> rcap
  def cap(str, {lcap, rcap}), do: lcap <> str <> rcap
  def cap(str, cap),          do:  cap <> str <> cap

  def cap_list(list, lcap, rcap),   do: lcap ++ list ++ rcap
  def cap_list(list, {lcap, rcap}), do: lcap ++ list ++ rcap
  def cap_list(list, cap),          do: cap  ++ list ++ cap

  def split_pads(len) do
    pad_len = div(len, 2)
    pad_wrap(pad_len, pad_len)
  end

  def ljust_pads(len) do
    {lpad_len, rem_len} = div_rem_two(len)
    pad_wrap(lpad_len, lpad_len + rem_len)
  end

  def rjust_pads(len) do
    {rpad_len, rem_len} = div_rem_two(len)
    pad_wrap(rpad_len + rem_len, rpad_len)
  end

  def wrap(right, left, :pre), do: {left, right} 
  def wrap(left, right, :app), do: {left, right} 

  def fetch_dims! do
    {:ok, rows} = :io.rows
    {:ok, cols} = :io.columns
    {rows, cols}
  end
end
