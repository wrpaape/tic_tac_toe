defmodule TicTacToe.Computer do
  use GenServer

  alias TicTacToe.Board.EndGame

  def start_link(game_info), do: GenServer.start_link(__MODULE__, game_info, name: __MODULE__)

  def next_move(board_tup),  do: GenServer.call(__MODULE__, {:next_move, board_tup}, :infinity)

  def state,                 do: GenServer.call(__MODULE__, :state)


  # external api ^

  def init(chars), do: {:ok, chars}

  def handle_call(:state, _from, state), do: {:ok, state, state}

  def handle_call({:next_move, {board, valids, win_state}}, _from, chars = {my_char, their_char}) do
    board
    |> IO.write

    best_move =
      valids
      |> Enum.reduce_while({[], [], valids}, fn(_move, {child_states, before_move, [move | after_move]})->
        move
        |> EndGame.next_win_state(my_char, win_state)
        |> case do
          done when is_number(done) ->
            {:halt, move}

          next_win_state ->
            {[{before_move, after_move, next_win_state, move} | child_states], [move | before_move], after_move}
            |> Utils.wrap_pre(:cont)
        end
      end)
      |> case do
        {child_states, _, _} ->
          num_children =
            child_states
            |> length

          collector_pid = 
            __MODULE__
            |> spawn(:collect, [nil, num_children, self])

          __MODULE__
          |> spawn(:reduce_child_states, [child_states, -0.5, {their_char, my_char}, num_children, collector_pid])

          receive do
            {_move_score, best_move} ->
              best_move
          end


        last_move ->
          last_move
      end

    best_move
    |> IO.write

    {:reply, best_move, chars}
  end

  def collect(best_score_tup, 0, parent_pid) do
    parent_pid
    |> send(best_score_tup)

    exit(:kill)
  end

  def collect(last_best_score_tup, rem_children, parent_pid) do
    receive do
      score_tup ->
        # IO.puts("#{inspect score_tup} #{rem_children}")
        last_best_score_tup
        |> max(score_tup)
        |> collect(rem_children - 1, parent_pid)
    end
  end

  def reduce_child_states(child_states, mult, {char, next_char}, num_children, collector_pid) do
    child_states
    # |> Enum.reduce(nil, fn({before_move, after_move, win_state, root_move}, last_score_tup)->
    |> Enum.each(fn({before_move, after_move, win_state, root_move})->
      rem_moves =
        before_move
        |> Enum.concat(after_move)

      rem_moves
      |> Enum.reduce_while({[], [], rem_moves}, fn(_move, {child_states, before_move, [move | after_move]})->
        move
        |> EndGame.next_win_state(char, win_state)
        |> case do
          done when is_number(done) ->
            {:halt, done * mult}

          next_win_state ->
            {[{before_move, after_move, next_win_state, root_move} | child_states], [move | before_move], after_move}
            |> Utils.wrap_pre(:cont)
        end
      end)
      |> case do
        {next_child_states, _, _} ->
          next_num_children = num_children - 1

          next_collector_pid = 
            __MODULE__
            |> spawn(:collect, [nil, next_num_children, collector_pid])

          __MODULE__
          |> spawn(:reduce_child_states, [next_child_states, -0.5 * mult, {next_char, char}, next_num_children, next_collector_pid])

         root_move_score ->
           collector_pid
           |> send({root_move_score, root_move})
      end
    end)

    exit(:kill)
  end
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
