defmodule SSCT do
  @input_file_path 'input/orders.csv'
  @output_file_path 'output/redemptions.csv'
  @header ["cash", "price", "wrappers needed", "type"]

  @doc """
  Reads orders from input file and writes redemptions to output file
  """
  def start(_type, _args) do
    read_orders() |> Trades.fill_orders |> write_redemptions

    Supervisor.start_link [], strategy: :one_for_one
  end

  defp read_orders do
    if File.exists?(@input_file_path),
      do: @input_file_path |> CSVLixir.read |> Enum.to_list,
    else: [@header]
  end

  defp write_redemptions(redemptions) do
    {:ok, file} = File.open @output_file_path, [:write, :utf8]

    redemptions |> Enum.each(fn redemption ->
      IO.write(file, redemption |> output_string)
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
