defmodule Demand.DialogButton do
  @moduledoc """
  Represents a button in a `Dialog`.
  """
  defstruct [
    label: "",
    value: nil
  ]

  @doc """
  Creates a new button with a label.
  Value defaults to label if not set.
  """
  def new(label) do
    %__MODULE__{label: label, value: label}
  end

  @doc """
  Sets a custom return value for the button.
  """
  def value(btn, val), do: %{btn | value: val}
end
