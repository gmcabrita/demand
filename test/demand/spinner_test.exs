defmodule Demand.SpinnerTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Demand.Spinner

  test "shows spinner and success message" do
    spinner = Spinner.new("Loading...")

    result = capture_io(fn ->
      Spinner.run(spinner, fn ->
        :timer.sleep(50) # Simulate work
        :done
      end)
    end)

    assert result =~ "Loading..."
    assert result =~ "✓"
  end
end
