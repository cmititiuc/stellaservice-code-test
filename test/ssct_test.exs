defmodule SSCTTest do
  use ExUnit.Case
  doctest SSCT

  test "greets the world" do
    assert SSCT.start() == :ok
  end
end
