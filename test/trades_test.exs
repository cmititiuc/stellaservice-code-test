defmodule TradesTest do
  use ExUnit.Case
  doctest Trades

  @header ["cash", "price", "wrappers needed", "type"]
  @input1 ["12", "2", "5", "milk"]
  @input2 ["12", "4", "4", "dark"]
  @input3 ["6", "2", "2", "sugar free"]
  @input4 ["6", "2", "2", "white"]
  @input5 ["0", "1", "2", "milk"]

  test "input1" do
    expected_output =
      [%{"dark" => 0, "milk" => 7, "sugar free" => 1, "white" => 0}]
    assert ([@header, @input1] |> Trades.fill_orders) == expected_output
  end

  test "input2" do
    expected_output =
      [%{"dark" => 3, "milk" => 0, "sugar free" => 0, "white" => 0}]
    assert ([@header, @input2] |> Trades.fill_orders) == expected_output
  end

  test "input3" do
    expected_output =
      [%{"dark" => 3, "milk" => 0, "sugar free" => 5, "white" => 0}]
    assert ([@header, @input3] |> Trades.fill_orders) == expected_output
  end

  test "input4" do
    expected_output =
      [%{"dark" => 1, "milk" => 0, "sugar free" => 3, "white" => 5}]
    assert ([@header, @input4] |> Trades.fill_orders) == expected_output
  end

  test "input5" do
    expected_output =
      [%{"dark" => 0, "milk" => 0, "sugar free" => 0, "white" => 0}]
    assert ([@header, @input5] |> Trades.fill_orders) == expected_output
  end
end
