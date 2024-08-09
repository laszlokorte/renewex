defmodule RenewexTest do
  use ExUnit.Case
  doctest Renewex

  test "initial test" do
    {:ok, example} = "./example_files/example.rnw" |> File.read()
    example |> Renewex.parse_string() |> dbg
  end
end
