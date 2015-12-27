defmodule TicTacToe.CLI do
  alias TicTacToe.Helper
  alias TicTacToe.Board
  alias TicTacToe.Computer
  alias TicTacToe.Player
  
  @valid_tokens Helper.get_config(:valid_tokens)
  @min_size     Helper.get_config(:min_size)
  @max_size     Helper.get_config(:max_size)
  @def_size     Helper.get_config(:def_size)
  @blink_cursor Helper.cap_reset("\n > ", :blink_slow)
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

  def process({size, _}) when size in @min_size..@max_size, do: process(size)
  def process({size, _}), do: alert_and_halt("board size must be an integer >= #{@min_size} and <= #{@max_size}")
  def process(:help),     do: alert_and_halt("usage: tic_tac_toe <size>", :blue)
  def process(:error),    do: alert_and_halt("failed to parse size (integer)")
  def process(size)       do
    size
    |> Board.start_link

    Computer.start_link
    
    {wrap, turn_str} =
      "heads or tails (h/t)?"
      |> Helper.str_app(@blink_cursor)
      |> IO.gets
      |> String.match?(coin_flip_reg)
      |> if do: {:wrap_app, "first"}, else: {:wrap_pre, "second"}

      turn_str
      |> Helper.cap("you will have the ", " move.\nchoose a valid (not whitespace or a number) token character")
      |> Helper.str_app(@blink_cursor)
      |> assign_tokens(wrap)
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

  #helpers V

  defp coin_flip_reg do
    ~w(h t)
    |> Enum.random
    |> Helper.str_pre("^")
    |> Regex.compile!("i")
  end

  def assign_tokens(prompt, wrap) do
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
      |> Helper.wrap_pre(Computer)
      |> Helper.app_wrap({Player, token}, wrap)
    else
      "invalid token"
      |> Helper.cap_reset(:red)
      |> IO.puts

      prompt
      |> assign_tokens(wrap)
    end
  end

  defp alert_and_halt(msg, color \\ :red) do
    msg   
    |> Helper.cap_reset(color)
    |> IO.puts

    System.halt(0)
  end
end
