# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config


valid_tokens =
  0x00400..0x3ffff
  |> Enum.map(&<<&1 :: 16>>)
  |> Enum.filter(fn(char)->
    String.valid_character?(char) and
    String.printable?(char)       and
    String.match?(char, ~r/[^\p{Z}\p{C}0-9]/)
  end)
  |> Enum.into(HashSet.new)

  move_lists = %{
    1: ~w(1),
    2: ~w(1 2
          q w),
    3: ~w(1 2 3
          q w e
          a s d),
    4: ~w(1 2 3 4
          q w e r
          a s d f
          z x c v)
  }

config :tic_tac_toe, [min_board_size: 1,
                      max_board_size: 4,
                      def_board_size: 3,
                      move_lists:     move_lists,
                      valid_tokens:   valid_tokens
]

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
