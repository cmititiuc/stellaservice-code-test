import String, only: [to_integer: 1]

defmodule Trades do
  @min_wrappers_needed 2
  @min_price 1

  @doc ~S"""
  Calculates redemptions based on orders.

  ## Examples

      iex> Trades.fill_orders([
      ...>   ["cash", "price", "wrappers needed", "type"],
      ...>   ["14", "2", "6", "milk"]
      ...> ])
      [%{"dark" => 0, "milk" => 8, "sugar free" => 1, "white" => 0}]

  Invalid orders:
    1. When the price is $0
      If the price is $0 then we enter an infinite loop, since it costs no money
      to buy a chocolate bar.
    2. When wrappers_needed is less than 2
      Since we get at least one new wrapper with each trade, if the number of
      wrappers needed for a trade is 1, we will enter an infinite loop. A value
      of 0 is invalid for the same reason as #1.

  Therefore, invalid orders are not processed.

      iex> Trades.fill_orders([
      ...>   ["cash", "price", "wrappers needed", "type"],
      ...>   ["14", "0", "6", "milk"]
      ...> ])
      [%{"dark" => 0, "milk" => 0, "sugar free" => 0, "white" => 0}]

      iex> Trades.fill_orders([
      ...>   ["cash", "price", "wrappers needed", "type"],
      ...>   ["14", "2", "1", "milk"]
      ...> ])
      [%{"dark" => 0, "milk" => 0, "sugar free" => 0, "white" => 0}]

  """
  def fill_orders(orders) do
    orders |> map_orders |> trade(:cash) |> trade(:wrappers) |> format
  end

  # Converts each csv input list into a map
  defp map_orders([[header1, header2, header3, header4] | orders]) do
    orders |> Enum.map(fn [col1, col2, col3, col4] ->
      %{header1 => col1,
        header2 => col2,
        header3 => col3,
        header4 => col4,
        "redemptions" => %{
          "milk" => 0, "dark" => 0, "white" => 0, "sugar free" => 0
        }
      }
    end)
  end

  # Remove all data that is not redemptions since we don't need it for the
  # final output
  defp format(orders), do: orders |> Enum.map(&(&1["redemptions"]))

  # Runs the orders through our algorithm to determine redemptions
  defp trade(orders, currency) do
    orders
    |> Enum.reduce([], fn(order, list) -> update_list(order, list, currency) end)
    |> Enum.reverse
  end

  # Accepts only orders that pass validation
  defp update_list(order, list, currency) do
    new_order =
      if order_is_valid?(order),
        do: update_order_redemptions_for(order, currency),
      else: order

    [new_order | list]
  end

  # Validates an order
  defp order_is_valid?(order) do
    [ to_integer(order["wrappers needed"]) >= @min_wrappers_needed,
      to_integer(order["price"]) >= @min_price
    ] |> Enum.all?(&(&1))
  end

  # Decides whether to update the cash part of the order or the wrappers part
  defp update_order_redemptions_for(order, currency) do
    if currency == :cash,
      do: update_order_with_cash_redemptions(order),
    else: update_order_with_wrapper_redemptions(order)
  end

  # Updates order with redemptions that were gained from trading cash
  defp update_order_with_cash_redemptions(
    order = %{
      "cash" => cash,
      "price" => price,
      "type" => type,
      "redemptions" => redemptions
    }
  ) do
    number_can_trade = get_number_can_trade(cash, price)
    cash_remaining = to_integer(cash) - number_can_trade * to_integer(price)

    %{order |
      "cash" => cash_remaining,
      "redemptions" => %{redemptions | type => number_can_trade}
    }
  end

  # Calculates floor of division between 2 numbers. Used to find how many trades
  # can be made (for either cash or wrappers)
  defp get_number_can_trade(num, denom) do
    num = if is_binary(num), do: to_integer(num), else: num
    denom = if is_binary(denom), do: to_integer(denom), else: denom

    if denom != 0, do: (num / denom) |> Float.floor |> trunc, else: 0
  end

  # Updates order with redemptions that were gained from trading wrappers
  defp update_order_with_wrapper_redemptions(
    order = %{"wrappers needed" => wrappers_needed, "redemptions" => redemptions}
  ) do
    %{order | "redemptions" => update_redemptions(redemptions, wrappers_needed)}
  end

  # Determines if the number of wrappers is sufficient to make a trade
  defp has_enough_for_trade?(wrappers, wrappers_needed) do
    wrappers
    |> Enum.any?(fn {_type, count} -> count >= wrappers_needed && count > 0 end)
  end

  # Recursively calculates redemptions
  defp update_redemptions(redemptions, wrappers_needed) do
    # copy redemptions since wrappers == redemptions at this point
    update_redemptions(redemptions, redemptions, wrappers_needed)
  end
  defp update_redemptions(redemptions, wrappers, wrappers_needed) do
    {updated_wrappers, updated_redemptions} =
      wrappers
      |> Enum.reduce({wrappers, redemptions}, fn({type, count}, inventory) ->
        get_inventory(inventory, wrappers_needed, count, type)
      end)

    if has_enough_for_trade?(updated_wrappers, to_integer(wrappers_needed)) do
      # Recursive call
      update_redemptions(updated_redemptions, updated_wrappers, wrappers_needed)
    else
      updated_redemptions
    end
  end

  # Decides whether the inventory needs updating
  defp get_inventory(inventory, wrappers_needed, count, type) do
    if get_number_can_trade(count, wrappers_needed) > 0,
      do: update_inventory(inventory, wrappers_needed, count, type),
    else: inventory
  end

  # Adds promotions to wrappers and redemptions
  defp update_inventory({wrappers, redemptions}, wrappers_needed, count, type) do
    number_can_trade = get_number_can_trade(count, wrappers_needed)
    wrappers_remaining =
      count - number_can_trade * to_integer(wrappers_needed)
    # subtract spent wrappers then add wrappers from promotional redemptions
    new_wrappers =
      %{wrappers | type => wrappers_remaining} |> add_promotions(type)
    # add chocolate bars from promotional redemptions iteratively
    new_redemptions = redemptions |> add_many_promotions(type, number_can_trade)

    {new_wrappers, new_redemptions}
  end

  # Recursively adds multiple promotions
  defp add_many_promotions(inventory, _type, 0), do: inventory
  defp add_many_promotions(inventory, type, count) do
    # Recursive call
    inventory |> add_promotions(type) |> add_many_promotions(type, count - 1)
  end

  # Updates inventory with promotions received
  defp add_promotions(
    inventory = %{
      "milk" => milk,
      "white" => white,
      "dark" => dark,
      "sugar free" => sugar_free
    },
    type
  ) do
    case type do
      "milk" ->
        %{inventory | "milk" => milk + 1, "sugar free" => sugar_free + 1}
      "white" ->
        %{inventory | "white" => white + 1, "sugar free" => sugar_free + 1}
      "sugar free" ->
        %{inventory | "dark" => dark + 1, "sugar free" => sugar_free + 1}
      "dark" ->
        %{inventory | "dark" => dark + 1}
      _ ->
        inventory
    end
  end
end
