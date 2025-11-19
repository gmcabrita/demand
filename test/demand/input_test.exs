defmodule Demand.InputTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Demand.Input

  test "reads input successfully" do
    input = Input.new("What is your name?")

    # Simulate typing "Alice" and hitting Enter (\r)
    user_input = "Alice\r"

    result = capture_io([input: user_input, capture_prompt: true], fn ->
      assert {:ok, "Alice"} = Input.run(input)
    end)

    # Check output contains prompt and what was typed
    assert result =~ "What is your name?"
    assert result =~ "Alice"
  end

  test "handles backspace" do
    input = Input.new("Name")
    # Type "Alix", Backspace, "ce", Enter
    # Backspace char is \x7f in Term.read_key
    user_input = "Alix\x7fce\r"

    capture_io([input: user_input, capture_prompt: true], fn ->
      assert {:ok, "Alice"} = Input.run(input)
    end)
  end

  test "handles left/right navigation and insertion" do
    input = Input.new("Name")
    # Type "Ale", Left, "ic", Right, Enter -> "Alice"
    # Left: \e[D
    # Right: \e[C
    user_input = "Ale\e[Dic\e[C\r"

    capture_io([input: user_input, capture_prompt: true], fn ->
      assert {:ok, "Alice"} = Input.run(input)
    end)
  end

  test "handles Ctrl+C (SIGINT)" do
    input = Input.new("Name")
    # Send Ctrl+C (\x03)
    user_input = "\x03"

    capture_io([input: user_input, capture_prompt: true], fn ->
      assert {:error, :interrupted} = Input.run(input)
    end)
  end
end
