defmodule Demand.ListTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Demand.List

  test "shows items" do
    list = List.new("Items")
      |> List.item("A")
      |> List.item("B")

    # Just enter to select first
    user_input = "\r"

    result = capture_io([input: user_input, capture_prompt: true], fn ->
      assert {:ok, "A"} = List.run(list)
    end)

    assert result =~ "Items"
    assert result =~ "A"
    assert result =~ "B"
  end
end
