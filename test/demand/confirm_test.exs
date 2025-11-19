defmodule Demand.ConfirmTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Demand.Confirm

  test "confirms with y" do
    confirm = Confirm.new("Yes?")
    user_input = "y"

    capture_io([input: user_input, capture_prompt: true], fn ->
      assert {:ok, true} = Confirm.run(confirm)
    end)
  end

  test "denies with n" do
    confirm = Confirm.new("Yes?")
    user_input = "n"

    capture_io([input: user_input, capture_prompt: true], fn ->
      assert {:ok, false} = Confirm.run(confirm)
    end)
  end

  test "toggles with arrow keys" do
    confirm = Confirm.new("Yes?")
    # Default is true (Yes)
    # Right (-> No), Enter
    user_input = "\e[C\r"

    capture_io([input: user_input, capture_prompt: true], fn ->
      assert {:ok, false} = Confirm.run(confirm)
    end)
  end
end
