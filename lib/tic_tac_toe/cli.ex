defmodule TicTacToe.CLI do
  alias TicTacToe.Helper
  alias TicTacToe.Board
  
  @default_size 3
  @valid_sizes  1..4
  @valid_reg    ~r/[^\p{Z}\p{C}0-9]/
  @valid_tokens 0x00400..0x3ffff
    |> Enum.map(&<<&1 :: 16>>)
    |> Enum.filter(&(String.valid_character?(&1) and String.printable?(&1) and String.match?(&1, @valid_reg)))
    |> Enum.into(HashSet.new)
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

  def process({board_size, _}) when board_size in @valid_sizes, do: process(board_size)
  def process({board_size, _}), do: alert_and_halt("board_size must be an integer > 0 and < 5")
  def process(:help),           do: alert_and_halt("usage: tic_tac_toe <board_size>", :blue)
  def process(:error),          do: alert_and_halt("failed to parse board_size (integer)")
  def process(board_size)       do
    {turns_tup, turn_str} =
      "heads or tails (h/t)?"
      |> Helper.str_app(@blink_cursor)
      |> IO.gets
      |> String.match?(coin_flip_reg)
      |> if do: {{true, false}, "first"}, else: {{false, true}, "second"}

    tokens_tup =
      turn_str
      |> Helper.cap("you will have the ", " move.\nchoose a valid (not whitespace or a number) token character")
      |> Helper.str_app(@blink_cursor)
      |> select_tokens
  end

  def parse_args(argv) do
    argv
    |> OptionParser.parse(@parse_opts)
    |> case do
      {[help: true], _, _ }         -> :help
       
      {_, [], _}                    -> @default_size
 
      {_, [board_size_str | _], _}  -> Integer.parse(board_size_str)
    end
  end

  #helpers V

  defp coin_flip_reg do
    ~w(h t)
    |> Enum.random
    |> Helper.str_pre("^")
    |> Regex.compile!("i")
  end

  def select_tokens(prompt) do
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
      |> Helper.wrap_pre(token)
    else
      "invalid token"
      |> Helper.cap_reset(:red)
      |> IO.puts

      prompt
      |> select_tokens
    end
  end

  defp alert_and_halt(msg, color \\ :red) do
    msg   
    |> Helper.cap_reset(color)
    |> IO.puts

    System.halt(0)
  end
end
