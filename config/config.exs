# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

alias IO.ANSI
alias Mix.Project

initial_valids =
  2
  |> :math.pow(10)
  |> trunc
  |> Range.new(0)
  |> Enum.map(&:unicode.characters_to_binary([&1]))
  |> Enum.filter(fn(cp)->
    is_binary(cp)
    and String.valid_character?(cp)
    and String.printable?(cp)
    and String.match?(cp, ~r/[^\p{Z}\p{C}]/)
  end)
  |> Enum.into(HashSet.new)

move_lists = [{1, ~w(1)},
              {2, ~w(1 2
                     q w)},
              {3, ~w(1 2 3
                     q w e
                     a s d)},
              {4, ~w(1 2 3 4
                     q w e r
                     a s d f
                     z x c v)}]

move_sets =
  move_lists
  |> Enum.map(fn({board_size, move_list})->
    lines =
      "─"
      |> String.duplicate(5)
      |> List.duplicate(board_size)

    top = "\n  ┌" <> Enum.join(lines, "┬") <> "┐"
    mid = "\n  ├" <> Enum.join(lines, "┼") <> "┤"
    bot = "\n  └" <> Enum.join(lines, "┴") <> "┘"

    body =
      move_list
      |> Enum.map(&inspect/1)
      |> Enum.chunk(board_size)
      |> Enum.map_join(mid, fn(row)->
        "\n  │ " <> Enum.join(row, " │ ") <> " │"
      end)

    valids =
      initial_valids
      |> Set.difference(Enum.into(move_list, HashSet.new))

    {board_size, {valids, top <> body <> bot <> "\n"}}
  end)

token_colors =
  ~w(red green blue cyan magenta yellow black)a
  |> Enum.map(fn(color)->
    ANSI.bright <> apply(ANSI, color, [])
  end)

config :tic_tac_toe, [min_board_size: 1,
                      max_board_size: 4,
                      def_board_size: 3,
                      # def_board_size: 4,
                      cursor:         ANSI.blink_slow <> "\n> " <> ANSI.reset,
                      token_colors:   token_colors,
                      move_lists:     Enum.into(move_lists, Map.new),
                      move_sets:      Enum.into(move_sets, Map.new)]

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :tic_tac_toe, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:tic_tac_toe, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
