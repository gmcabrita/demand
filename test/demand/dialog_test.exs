defmodule Demand.DialogTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Demand.Dialog

  test "shows buttons and selects default" do
    dialog = Dialog.new("Alert")
      |> Dialog.buttons(["OK", "Cancel"])
      |> Dialog.selected_button(0)

    # Enter to select default (OK)
    user_input = "\r"

    result = capture_io([input: user_input, capture_prompt: true], fn ->
      assert {:ok, "OK"} = Dialog.run(dialog)
    end)

    assert result =~ "Alert"
    assert result =~ "OK"
    assert result =~ "Cancel"
  end
end
