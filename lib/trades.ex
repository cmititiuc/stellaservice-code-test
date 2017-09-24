import String, only: [to_integer: 1]

defmodule Trades do
  def fill_orders(order_list) do
    order_list |> map_order_list |> trade(:cash) |> trade(:wrappers)
  end

  defp map_order_list([[header1, header2, header3, header4] | orders]) do
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

  defp trade(order_list, currency) do
    order_list
    |> Enum.reduce([], fn(order, list) ->
      [update_order_redemptions_for(order, currency) | list]
    end)
    |> Enum.reverse
  end

  defp update_order_redemptions_for(order, currency) do
    if currency == :cash,
      do: update_order_with_cash_redemptions(order),
      else: update_order_with_wrapper_redemptions(order)
  end

  defp get_number_can_trade(num, denom) do
    num = if is_binary(num), do: to_integer(num), else: num
    denom = if is_binary(denom), do: to_integer(denom), else: denom

    if denom != 0, do: (num / denom) |> Float.floor |> trunc, else: 0
  end

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

  defp update_order_with_wrapper_redemptions(
    order = %{"wrappers needed" => wrappers_needed, "redemptions" => redemptions}
  ) do
    %{order | "redemptions" => update_redemptions(redemptions, wrappers_needed)}
  end

  defp can_trade?(wrappers, wrappers_needed) do
    wrappers
    |> Enum.any?(fn {_type, count} -> count >= wrappers_needed && count > 0 end)
  end

  defp update_redemptions(redemptions, wrappers_needed) do
    update_redemptions(redemptions, redemptions, wrappers_needed)
  end
  defp update_redemptions(redemptions, wrappers, wrappers_needed) do
    {updated_wrappers, updated_redemptions} =
      wrappers
      |> Enum.reduce({wrappers, redemptions}, fn({type, count}, inventory) ->
        get_inventory(inventory, wrappers_needed, count, type)
      end)

    if can_trade?(updated_wrappers, to_integer(wrappers_needed)) do
      update_redemptions(updated_redemptions, updated_wrappers, wrappers_needed)
    else
      updated_redemptions
    end
  end

  defp get_inventory(inventory, wrappers_needed, count, type) do
    if get_number_can_trade(count, wrappers_needed) > 0 do
      update_inventory(inventory, wrappers_needed, count, type)
    else
      inventory
    end
  end

  defp update_inventory({wrappers, redemptions}, wrappers_needed, count, type) do
    number_can_trade = get_number_can_trade(count, wrappers_needed)
    wrappers_remaining =
      count - number_can_trade * to_integer(wrappers_needed)
    # subtract spent wrappers then add wrappers from promotional redemptions
    new_wrappers =
      %{wrappers | type => wrappers_remaining} |> add_promotions(type)
    new_redemptions = add_many_promotions(redemptions, type, number_can_trade)

    {new_wrappers, new_redemptions}
  end

  defp add_many_promotions(redemptions, _type, 0), do: redemptions
  defp add_many_promotions(redemptions, type, count) do
    redemptions |> add_promotions(type) |> add_many_promotions(type, count - 1)
  end

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
