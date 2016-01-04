defmodule TicTacToe.CLI do
  alias TicTacToe.Board
  alias TicTacToe.Computer
  alias TicTacToe.Player
  
  require Misc

  @valids Misc.get_config(:valid_tokens)
  @min    Misc.get_config(:min_board_size)
  @max    Misc.get_config(:max_board_size)
  @def    Misc.get_config(:def_board_size)
  @cursor Misc.cap_reset("\n > ", :blink_slow)
  @parse_opts [
    switches: [help: :boolean],
    aliases:  [h:    :help]
  ]

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  #external API ^

  def process({board_size, __}) when board_size in @min..@max, do: process(board_size)
  def process({_board_size, _}), do: alert("board size must be >= #{@min} and <= #{@max}")
  def process(:error),           do: alert("failed to parse integeer from board size")
  def process(:help),            do: alert("usage: tic_tac_toe (<board size>)", :blue)
  def process(board_size)        do
    board_size
    |> Board.start_link

    {wrap_dir, turn_str} =
      "heads or tails (h/t)?"
      |> Misc.str_app(@cursor)
      |> IO.gets
      |> String.match?(coin_flip_reg)
      |> if do: {:app, "first"}, else: {:pre, "second"}

    turn_str
    |> Misc.cap("you will have the ", " move.\nchoose a valid (not whitespace or a number) token character")
    |> Misc.str_app(@cursor)
    |> assign_tokens(wrap_dir)
    |> TicTacToe.start
  end

  def parse_args(argv) do
    argv
    |> OptionParser.parse(@parse_opts)
    |> case do
      {[help: true], _, _ }  -> :help
       
      {_, [], _}             -> @def
 
      {_, [size_str | _], _} -> Integer.parse(size_str)
    end
  end

  #helpers v 

  defp coin_flip_reg do
    ~w(h t)
    |> Enum.random
    |> Misc.str_pre("^")
    |> Regex.compile!("i")
  end

  def assign_tokens(prompt, wrap_dir) do
    token =
      prompt
      |> IO.gets
      |> String.first

    @valids
    |> Set.member?(token)
    |> if do
      @valids
      |> Set.delete(token)
      |> Enum.random
      |> Misc.wrap_pre(Computer)
      |> Misc.wrap({Player, token}, wrap_dir)
    else
      "invalid token"
      |> Misc.cap_reset(:red)
      |> IO.puts

      prompt
      |> assign_tokens(wrap_dir)
    end
  end

  defmacrop alert(msg, color \\ :red) do
    quote do
      unquote(msg)   
      |> Misc.cap_reset(unquote(color))
      |> IO.puts

      System.halt(0)
    end
  end
end
