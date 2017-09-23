defmodule TradesTest do
  use ExUnit.Case
  doctest Trades

  test "example data" do
    orders = [
      ["cash", "price", "wrappers needed", "type"],
      ["14", "2", "6", "milk"],
      ["12", "2", "5", "milk"],
      ["12", "4", "4", "dark"],
      ["6", "2", "2", "sugar free"],
      ["6", "2", "2", "white"],
      ["0", "0", "0", "milk"]
    ]

    expected_results = [
      %{"cash" => 0, "price" => "2", "redemptions" => %{
        "dark" => 0, "milk" => 8, "sugar free" => 1, "white" => 0
      }, "type" => "milk", "wrappers needed" => "6"},
      %{"cash" => 0, "price" => "2", "redemptions" => %{
        "dark" => 0, "milk" => 7, "sugar free" => 1, "white" => 0
      }, "type" => "milk", "wrappers needed" => "5"},
      %{"cash" => 0, "price" => "4", "redemptions" => %{
        "dark" => 3, "milk" => 0, "sugar free" => 0, "white" => 0
      }, "type" => "dark", "wrappers needed" => "4"},
      %{"cash" => 0, "price" => "2", "redemptions" => %{
        "dark" => 3, "milk" => 0, "sugar free" => 5, "white" => 0
      }, "type" => "sugar free", "wrappers needed" => "2"},
      %{"cash" => 0, "price" => "2", "redemptions" => %{
        "dark" => 1, "milk" => 0, "sugar free" => 3, "white" => 5
      }, "type" => "white", "wrappers needed" => "2"},
      %{"cash" => 0, "price" => "0", "redemptions" => %{
        "dark" => 0, "milk" => 0, "sugar free" => 0, "white" => 0
      }, "type" => "milk", "wrappers needed" => "0"}
    ]

    assert (orders |> Trades.fill_orders) == expected_results
  end
end
