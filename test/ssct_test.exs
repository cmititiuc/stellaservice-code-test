defmodule SSCTTest do
  use ExUnit.Case

  test "starts link" do
    {status, pid} = SSCT.start(nil, nil)
    assert status == :ok
    assert pid |> is_pid
  end
end
