alias String, as: S

defmodule SSCT do
  def start(_type, _args) do
    read_order_list()
    |> map_order_list
    # |> print_order_list
    |> trade
    # |> print_redemptions
    |> write_order_list

    Supervisor.start_link [], strategy: :one_for_one
  end

  def trade(order_list) do
    order_list |> trade_cash |> trade_wrappers
  end

  defp trade_cash(order_list) do
    order_list
    |> Enum.reduce([], fn(order, list) ->
      %{"cash" => cash,
        "price" => price,
        "wrappers needed" => wrappers_needed,
        "type" => type,
        "redemptions" => redemption
      } = order

      number_can_buy =
        S.to_integer(cash) / S.to_integer(price) |> Float.floor |> trunc
      cash_remaining = S.to_integer(cash) - number_can_buy * S.to_integer(price)

      updated_order = %{
        "cash" => cash_remaining,
        "price" => price,
        "wrappers needed" => wrappers_needed,
        "type" => type,
        "redemptions" => %{redemption | type => number_can_buy}
      }

      [updated_order | list]
    end)
    |> Enum.reverse
  end

  defp trade_wrappers(order_list) do
    order_list
    |> Enum.reduce([], fn(order, list) ->
      %{"cash" => cash,
        "price" => price,
        "wrappers needed" => wrappers_needed,
        "type" => type,
        "redemptions" => redemption
      } = order

      updated_order = %{
        "cash" => cash,
        "price" => price,
        "wrappers needed" => wrappers_needed,
        "type" => type,
        "redemptions" => redemption |> make_trades(wrappers_needed)
      }

      [updated_order | list]
    end)
    |> Enum.reverse
  end

  defp make_trades(redemption, wrappers_needed) do
    make_trades(redemption, redemption, wrappers_needed)
  end

  defp make_trades(redemption, wrappers, wrappers_needed) do
    {updated_wrappers, updated_redemption} =
      wrappers
      |> Enum.reduce({wrappers, redemption}, fn({type, count}, acc) ->
        number_can_trade =
          count / S.to_integer(wrappers_needed)
          |> Float.floor
          |> trunc

        if number_can_trade <= 0 do
          {elem(acc, 0), elem(acc, 1)}
        else
          wrappers_remaining =
            count - number_can_trade * S.to_integer(wrappers_needed)

          # subtract spent wrappers
          new_wrappers = %{elem(acc, 0) | type => wrappers_remaining}

          # add wrappers from promotional items received
          new_wrappers =
            case type do
              "milk" ->
                new = %{new_wrappers | "milk" => new_wrappers["milk"] + 1}
                new = %{new | "sugar free" => new_wrappers["sugar free"] + 1}
                new
              "white" ->
                new = %{new_wrappers | "white" => new_wrappers["white"] + 1}
                new = %{new | "sugar free" => new_wrappers["sugar free"] + 1}
                new
              "sugar free" ->
                new = %{new_wrappers | "dark" => new_wrappers["dark"] + 1}
                new = %{new | "sugar free" => new_wrappers["sugar free"] + 1}
                new
              "dark" ->
                new = %{new_wrappers | "dark" => new_wrappers["dark"] + 1}
                new
              _ ->
                new_wrappers
            end

          new_redemption = update_redemption(elem(acc, 1), type, number_can_trade)

          {new_wrappers, new_redemption}
        end
      end)

    if can_trade?(updated_wrappers, String.to_integer(wrappers_needed)) do
      make_trades(updated_redemption, updated_wrappers, wrappers_needed)
    else
      updated_redemption
    end
  end

  defp update_redemption(redemption, _type, 0), do: redemption
  defp update_redemption(redemption, type, count) do
    new_redemption =
      case type do
        "milk" ->
          new = %{redemption | "milk" => redemption["milk"] + 1}
          new = %{new | "sugar free" => redemption["sugar free"] + 1}
          new
        "white" ->
          new = %{redemption | "white" => redemption["white"] + 1}
          new = %{new | "sugar free" => redemption["sugar free"] + 1}
          new
        "sugar free" ->
          new = %{redemption | "dark" => redemption["dark"] + 1}
          new = %{new | "sugar free" => redemption["sugar free"] + 1}
          new
        "dark" ->
          new = %{redemption | "dark" => redemption["dark"] + 1}
          new
        _ ->
          redemption
      end

    update_redemption(new_redemption, type, count - 1)
  end

  defp can_trade?(wrappers, wrappers_needed) do
    wrappers |> Enum.any?(fn({_type, count}) -> count >= wrappers_needed end)
  end

  defp read_order_list do
    'input/orders.csv' |> CSVLixir.read |> Enum.to_list
  end

  defp write_order_list(order_list) do
    {:ok, file} = File.open "output/redemptions.csv", [:write]

    order_list |> Enum.each(
      fn %{"redemptions" => %{
        "dark" => dark,
        "milk" => milk,
        "white" => white,
        "sugar free" => sugar_free
      }} ->
        file |> IO.binwrite(
          "milk #{milk},dark #{dark},white #{white},sugar free #{sugar_free}\n"
        )
      end
    )

    File.close file
  end

  def map_order_list([[header1, header2, header3, header4] | orders]) do
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

  defp print_order_list(order_list) do
    IO.puts "#### input"

    order_list |> Enum.each(
      fn %{
        "cash" => cash,
        "price" => price,
        "wrappers needed" => wrappers_needed,
        "type" => type,
        "redemptions" => %{
          "dark" => dark,
          "milk" => milk,
          "white" => white,
          "sugar free" => sugar_free
        }
      } ->
        IO.puts "\n  cash: #{cash}, price: #{price}, " <>
          "wrappers needed: #{wrappers_needed}, type: #{type}\n"
        # IO.puts "\n  dark: #{dark}, milk: #{milk}, white: #{white}, " <>
        #   "sugar free: #{sugar_free}\n"
      end
    )
    order_list
  end

  defp print_redemptions(order_list) do
    IO.puts "#### output ####"

    order_list |> Enum.each(
      fn %{
        "cash" => cash,
        "price" => price,
        "wrappers needed" => wrappers_needed,
        "type" => type,
        "redemptions" => %{
          "dark" => dark,
          "milk" => milk,
          "white" => white,
          "sugar free" => sugar_free
        }
      } ->
        # IO.puts "cash: #{cash}, price: #{price}, " <>
        #   "wrappers needed: #{wrappers_needed}, type: #{type} "
        IO.puts "\n  dark: #{dark}, milk: #{milk}, white: #{white}, " <>
          "sugar free: #{sugar_free}\n"
      end
    )
    order_list
  end
end
