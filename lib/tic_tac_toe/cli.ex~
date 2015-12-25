defmodule TicTacToe.CLI do
  alias IO.ANSI
  alias TicTacToe.Helper

  @parse_opts [
    switches: [help: :boolean],
    aliases:  [h:    :help]
  ]

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def process(:help) do
    "failed to parse board_size (integer)"
    |> Helper.cap(ANSI.red, ANSI.reset)
  end
  
  def process(:error) do
    "failed to parse board_size (integer)"
    |> Helper.cap(ANSI.red, ANSI.reset)
  end
   
  def process({board_size, _}) do
    
  end

  def parse_args(argv) do
    argv
    |> OptionParser.parse(@parse_opts)
    |> case do
       {[help: true], _, _ }     -> :help
       
       {_, [], _}                -> :help
 
       {_, [board_size_str], _}  -> Integer.parse(board_size_str)
    end
  end
end
