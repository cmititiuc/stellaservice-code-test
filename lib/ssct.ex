defmodule SSCT do
  def start(_type, _args) do
    read_order_list() |> map_order_list |> print_order_list

    Supervisor.start_link [], strategy: :one_for_one
  end

  defp read_order_list do
    'input/orders.csv' |> CSVLixir.read |> Enum.to_list
  end

  defp map_order_list([[header1, header2, header3, header4] | orders]) do
    orders |> Enum.map(fn [col1, col2, col3, col4] ->
      %{header1 => col1, header2 => col2, header3 => col3, header4 => col4}
    end)
  end

  defp print_order_list(order_list) do
    order_list |> Enum.each(
      fn %{
        "cash" => cash,
        "price" => price,
        "wrappers needed" => wrappers_needed,
        "type" => type
      } ->
        IO.puts "cash: #{cash}, price: #{price}, " <>
          "wrappers needed: #{wrappers_needed}, type: #{type}"
      end
    )
  end
end
