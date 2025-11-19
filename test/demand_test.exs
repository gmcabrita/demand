defmodule DemandTest do
  use ExUnit.Case
  doctest Demand

  test "API delegates exist" do
    assert function_exported?(Demand, :input, 1)
    assert function_exported?(Demand, :select, 1)
    assert function_exported?(Demand, :multi_select, 1)
    assert function_exported?(Demand, :confirm, 1)
    assert function_exported?(Demand, :spinner, 1)
    assert function_exported?(Demand, :dialog, 1)
    assert function_exported?(Demand, :list, 1)
  end
end
