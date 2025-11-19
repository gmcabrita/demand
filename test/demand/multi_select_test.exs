defmodule Demand.MultiSelectTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Demand.MultiSelect

  test "selects multiple options" do
    select = MultiSelect.new("Toppings")
      |> MultiSelect.option("Cheese")
      |> MultiSelect.option("Pepperoni")
      |> MultiSelect.option("Mushrooms")

    # Space (select first), Down, Space (select second), Enter
    # Down: \e[B
    user_input = " \e[B \r"

    capture_io([input: user_input, capture_prompt: true], fn ->
      assert {:ok, ["Cheese", "Pepperoni"]} = MultiSelect.run(select)
    end)
  end
end
