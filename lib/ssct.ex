defmodule SSCT do
  def start(_type, _args) do
    read_order_list()
    |> Trades.fill_orders
    # |> print_redemptions
    |> write_redemptions

    Supervisor.start_link [], strategy: :one_for_one
  end

  defp read_order_list do
    'input/orders.csv' |> CSVLixir.read |> Enum.to_list
  end

  defp write_redemptions(order_list) do
    output_string = fn(milk, dark, white, sugar_free) ->
      "milk #{milk},dark #{dark},white #{white},sugar free #{sugar_free}\n"
    end
    {:ok, file} = File.open "output/redemptions.csv", [:write]

    order_list |> Enum.each(
      fn %{"redemptions" => %{
        "dark" => dark,
        "milk" => milk,
        "white" => white,
        "sugar free" => sugar_free
      }} ->
        IO.binwrite(file, output_string.(dark, milk, white, sugar_free))
      end
    )

    File.close file
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
