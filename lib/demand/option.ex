defmodule Demand.Option do
  defstruct [
    value: nil,
    label: nil,
    description: nil,
    selected: false
  ]

  def new(value) do
    %__MODULE__{value: value, label: value}
  end

  def label(opt, label), do: %{opt | label: label}
  def description(opt, desc), do: %{opt | description: desc}
  def selected(opt, sel \\ true), do: %{opt | selected: sel}
end
