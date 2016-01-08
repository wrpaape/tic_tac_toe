defmodule TicTacToe.Board.EndGame do
  
  def next_win_state(move, char, win_state), do: next_info(move, char, win_state, [])
  # external API ^

  # helpers v

  defmacrop recurse(next_acc_state) do
    quote do
      next_info(var!(move), var!(char), var!(rem_state), unquote(next_acc_state))
    end
  end

  defmacrop push_next(next_info) do
    quote do: recurse([unquote(next_info) | var!(acc_state)])
  end

  defmacrop reduce_owned_or_unclaimed_info_and_recurse do
    quote do
      var!(win_set)
      |> Set.delete(var!(move))
      |> case do
        %HashSet{size: ^var!(size)} -> push_next(var!(info))
        %HashSet{size: 0}           -> 1
        next_win_set                -> push_next({next_win_set, var!(char)})
      end
    end
  end

  def next_info(move, char, [info = win_set = %HashSet{size: size} | rem_state], acc_state) do
    reduce_owned_or_unclaimed_info_and_recurse
  end

  def next_info(move, char, [info = {win_set = %HashSet{size: size}, char} | rem_state], acc_state) do
    reduce_owned_or_unclaimed_info_and_recurse
  end

  def next_info(move, char, [occ_info | rem_state], acc_state) do
    occ_info
    |> elem(0)
    |> Set.member?(move)
    |> if(do: recurse(acc_state), else: push_next(occ_info))
  end

  def next_info(_move, _token, [], []),             do: 0
  def next_info(_move, _token, [], next_win_state), do: next_win_state
end
