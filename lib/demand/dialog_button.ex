defmodule Demand.DialogButton do
  defstruct [
    label: "",
    value: nil
  ]

  def new(label) do
    %__MODULE__{label: label, value: label}
  end

  def value(btn, val), do: %{btn | value: val}
end
