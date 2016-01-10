defmodule TicTacToe.Computer do
  use GenServer

  alias TicTacToe.Board.EndGame

  def start_link(game_info), do: GenServer.start_link(__MODULE__, game_info, name: __MODULE__)

  def next_move(board_tup),  do: GenServer.call(__MODULE__, {:next_move, board_tup}, :infinity)

  def state,                 do: GenServer.call(__MODULE__, :state)


  # external api ^

  def init({my_char, their_char}) do
    Map.new
    |> Map.put(1, my_char)
    |> Map.put(-1, their_char)
    |> Utils.wrap_pre(:ok)
  end

  def handle_call(:state, _from, state), do: {:ok, state, state}

  def handle_call({:next_move, {board, valids, win_state}}, _from, chars = %{1 => my_char}) do
    board
    |> IO.write

    score_moves =
      valids
      |> Enum.map_reduce({[], valids}, fn(_move, {before_move, [move | after_move]})->
        move
        |> EndGame.next_win_state(my_char, win_state)
        |> reduce_branch(-1, chars, before_move, after_move)
        |> flip
        |> Utils.wrap_app(move)
        |> Utils.wrap_app({[move | before_move], after_move})
      end)
      |> elem(0)
      |> IO.inspect

    best_move =
      score_moves
      |> Enum.max
      |> elem(1)

    {:reply, best_move, chars}
  end

  def reduce_branch(done, mult, _, _, _) when is_number(done),     do: done * mult
  def reduce_branch(win_state, mult, chars, before_rem, after_rem) do
    char =
      chars
      |> Map.get(mult)

    rem_moves =
      before_rem
      |> Enum.concat(after_rem)

    next_mult =
      mult
      |> flip

    rem_moves
    |> Enum.reduce({-2, [], rem_moves}, fn(_move, {last_score, before_move, [move | after_move]})->
      # IO.puts("last_score: #{last_score}, move: #{move}, bef: #{before_move}, aft: #{after_move} char: #{char}")

      next_score =
        move
        |> EndGame.next_win_state(char, win_state)
        |> reduce_branch(next_mult, chars, before_move, after_move)
        |> flip
        |> max(last_score)

      {next_score, [move | before_move], after_move}
    end)
    |> elem(0)
  end

  defp flip(num), do: num * -1
end

      # worker_pid =
      #   __MODULE__
      #   |> spawn(:sum_branch, [win_state, chars, before_move, after_move, move, collector_pid])


    # collector_pid =
    #   __MODULE__
    #   |> spawn(:collect, [nil, length(valids), HashSet.new, self])
    


#     receive do
#       {dead_workers, best_move} ->
#         branch_workers
#         |> Set.difference(dead_workers)
#         |> Enum.each(&Process.exit(&1, :kill))

#         best_move
#         |> IO.write

#       {:reply, best_move, chars}
#     end
#   end

#   # def do_branch(done, mult, chars, _, _) when is_number(done) do
#     # IO.inspect("node score: #{done}, mult: #{mult}, char: #{chars[mult]}")
#     # done * mult
#   # end
#   def do_branch(rem_moves, mult, chars, win_state) do
#     char =
#       chars
#       |> Map.get(mult)

#     rem_moves
#     |> Enum.reduce_while({[], [], rem_moves}, fn(_move, {next_branches, before_move, [move | after_move]})->
#         move
#         |> EndGame.next_win_state(char, win_state)
#         |> case do
#           done when is_number(done) ->
#             {:halt, done}

#           next_win_state ->

#             {:cont, {[{before_move, after_move, next_win_state}], [move | before_move], after_move}}
#         end
#     end)
#     |> case do
#       {next_branches, _, _} ->
#         next_mult = mult * -1

#         next_branches
#         |> Enum.reduce(-2, fn({before_move, after_move, next_win_state}, last_score)->
#           branch_score =
#             before_move
#             |> Enum.concat(after_move)
#             |> do_branch(next_mult, chars, next_win_state)
          
#           IO.puts("last: #{last_score}, this: #{branch_score}")

#           last_score
#           |> max(-branch_score)
#         end)

#       done ->
#         IO.puts("STOOP done: #{done * mult} char: #{char}")
#         done * mult
#     end
#         |> (&(&1 * -1)).()
#   end

#   def sum_branch(win_state, chars = %{1 => my_char}, before_move, after_move, move, collector_pid) do
#     msg =
#       move
#       |> EndGame.next_win_state(my_char, win_state)
#       |> case do
#         done when is_number(done) ->
#           :game_over

#         next_win_state ->
#           before_move
#           |> Enum.concat(after_move)
#           |> do_branch(-1, chars, next_win_state)
#       end

#     collector_pid
#     |> send({msg, move, self})

#     exit(:kill)
#   end

#   # helpers v

#   def collect({_, best_move}, 0, dead_workers, root_pid) do
#     root_pid 
#     |> send({dead_workers, best_move})

#     exit(:kill)
#   end

#   def collect(last_max, rem_moves, dead_workers, root_pid) do
#     receive do
#       {:game_over, best_move, worker_pid} ->
#         IO.puts("game over #{best_move}")

#         root_pid
#         |> send({Set.put(dead_workers, worker_pid), best_move})

#       {score, move, worker_pid} ->
#         {score, move}
#         |> IO.inspect
#         |> max(last_max)
#         |> collect(rem_moves - 1, Set.put(dead_workers, worker_pid), root_pid)
#     end
#   end
# end
