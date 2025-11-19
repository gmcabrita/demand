defmodule Demand.SelectTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Demand.Select

  test "selects an option" do
    select = Select.new("Choose")
      |> Select.option("A")
      |> Select.option("B")
      |> Select.option("C")

    # Down arrow, Enter
    # Down arrow is \e[B
    user_input = "\e[B\r"

    result = capture_io([input: user_input, capture_prompt: true], fn ->
      assert {:ok, "B"} = Select.run(select)
    end)
    
    assert result =~ "Choose"
    assert result =~ "B"
  end

  test "filters options" do
    select = Select.new("Choose")
      |> Select.option("Apple")
      |> Select.option("Banana")
      |> Select.option("Cherry")
      |> Select.filterable(true)

    # Type "Ba", Enter
    user_input = "Ba\r"

    capture_io([input: user_input, capture_prompt: true], fn ->
      assert {:ok, "Banana"} = Select.run(select)
    end)
  end
end
