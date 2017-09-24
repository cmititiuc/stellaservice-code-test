defmodule SSCT do
  def start(_type, _args) do
    read_orders() |> Trades.fill_orders |> write_redemptions

    Supervisor.start_link [], strategy: :one_for_one
  end

  defp read_orders do
    'input/orders.csv' |> CSVLixir.read |> Enum.to_list
  end

  defp write_redemptions(orders) do
    {:ok, file} = File.open "output/redemptions.csv", [:write]

    orders |> Enum.each(fn %{"redemptions" => redemptions} ->
      IO.binwrite(file, redemptions |> output_string)
    end)

    File.close file
  end

  defp output_string(%{
    "milk" => milk,
    "dark" => dark,
    "white" => white,
    "sugar free" => sugar_free
  }) do
    "milk #{milk},dark #{dark},white #{white},sugar free #{sugar_free}\n"
  end
end
