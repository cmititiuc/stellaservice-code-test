defmodule SSCTTest do
  use ExUnit.Case
  doctest SSCT

  test "starts link" do
    {status, pid} = SSCT.start(nil, nil)
    assert status == :ok
    assert pid |> is_pid
  end

  test "example data" do
    result = [
      ["cash", "price", "wrappers needed", "type"],
      ["14", "2", "6", "milk"],
      ["12", "2", "5", "milk"],
      ["12", "4", "4", "dark"],
      ["6", "2", "2", "sugar free"],
      ["6", "2", "2", "white"]
    ] |> SSCT.map_order_list |> SSCT.trade

    assert result == [
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
      }, "type" => "white", "wrappers needed" => "2"}
    ]
  end
end
