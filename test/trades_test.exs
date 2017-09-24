defmodule TradesTest do
  use ExUnit.Case
  doctest Trades

  @header ["cash", "price", "wrappers needed", "type"]
  @input1 ["14", "2", "6", "milk"]
  @input2 ["12", "2", "5", "milk"]
  @input3 ["12", "4", "4", "dark"]
  @input4 ["6", "2", "2", "sugar free"]
  @input5 ["6", "2", "2", "white"]
  @input6 ["0", "0", "0", "milk"]

  test "input1" do
    expected_output = [%{"cash" => 0, "price" => "2", "redemptions" => %{
      "dark" => 0, "milk" => 8, "sugar free" => 1, "white" => 0
    }, "type" => "milk", "wrappers needed" => "6"}]
    assert ([@header, @input1] |> Trades.fill_orders) == expected_output
  end

  test "input2" do
    expected_output = [%{"cash" => 0, "price" => "2", "redemptions" => %{
      "dark" => 0, "milk" => 7, "sugar free" => 1, "white" => 0
    }, "type" => "milk", "wrappers needed" => "5"}]
    assert ([@header, @input2] |> Trades.fill_orders) == expected_output
  end

  test "input3" do
    expected_output = [%{"cash" => 0, "price" => "4", "redemptions" => %{
      "dark" => 3, "milk" => 0, "sugar free" => 0, "white" => 0
    }, "type" => "dark", "wrappers needed" => "4"}]
    assert ([@header, @input3] |> Trades.fill_orders) == expected_output
  end

  test "input4" do
    expected_output = [%{"cash" => 0, "price" => "2", "redemptions" => %{
      "dark" => 3, "milk" => 0, "sugar free" => 5, "white" => 0
    }, "type" => "sugar free", "wrappers needed" => "2"}]
    assert ([@header, @input4] |> Trades.fill_orders) == expected_output
  end

  test "input5" do
    expected_output = [%{"cash" => 0, "price" => "2", "redemptions" => %{
      "dark" => 1, "milk" => 0, "sugar free" => 3, "white" => 5
    }, "type" => "white", "wrappers needed" => "2"}]
    assert ([@header, @input5] |> Trades.fill_orders) == expected_output
  end

  test "input6" do
    expected_output = [%{"cash" => 0, "price" => "0", "redemptions" => %{
      "dark" => 0, "milk" => 0, "sugar free" => 0, "white" => 0
    }, "type" => "milk", "wrappers needed" => "0"}]
    assert ([@header, @input6] |> Trades.fill_orders) == expected_output
  end
end
