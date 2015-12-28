defmodule TicTacToe.CLI do
  alias TicTacToe.Board
  alias TicTacToe.Computer
  alias TicTacToe.Player
  
  require Misc

  @valid_tokens Misc.get_config(:valid_tokens)
  @min_size     Misc.get_config(:min_size)
  @max_size     Misc.get_config(:max_size)
  @def_size     Misc.get_config(:def_size)
  @blink_cursor Misc.cap_reset("\n > ", :blink_slow)
  @parse_opts   [
    switches: [help: :boolean],
    aliases:  [h:    :help]
  ]

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  #external API ^

  def process({size, __}) when size in @min_size..@max_size, do: process(size)
  def process({_size, _}), do: alert("board size must be >= #{@min_size} and <= #{@max_size}")
  def process(:error),     do: alert("failed to parse integeer from board size")
  def process(:help),      do: alert("usage: tic_tac_toe (<board size>)", :blue)
  def process(size)        do
    size
    |> Board.start_link

    {wrap_dir, turn_str} =
      "heads or tails (h/t)?"
      |> Misc.str_app(@blink_cursor)
      |> IO.gets
      |> String.match?(coin_flip_reg)
      |> if do: {:app, "first"}, else: {:pre, "second"}

    turn_str
    |> Misc.cap("you will have the ", " move.\nchoose a valid (not whitespace or a number) token character")
    |> Misc.str_app(@blink_cursor)
    |> assign_tokens(wrap_dir)
    |> TicTacToe.start
  end

  def parse_args(argv) do
    argv
    |> OptionParser.parse(@parse_opts)
    |> case do
      {[help: true], _, _ }  -> :help
       
      {_, [], _}             -> @def_size
 
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

    @valid_tokens
    |> Set.member?(token)
    |> if do
      @valid_tokens
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

  defp alert(msg, color \\ :red) do
    msg   
    |> Misc.cap_reset(color)
    |> IO.puts

    System.halt(0)
  end
end
