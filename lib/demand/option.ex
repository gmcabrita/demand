defmodule Demand.Option do
  @moduledoc """
  Represents an option in a selection list (`Select`, `MultiSelect`, `List`).
  """
  defstruct [
    value: nil,
    label: nil,
    description: nil,
    selected: false
  ]

  @doc """
  Creates a new Option with the given value (and label defaulting to value).
  """
  def new(value) do
    %__MODULE__{value: value, label: value}
  end

  @doc """
  Sets the display label for the option.
  """
  def label(opt, label), do: %{opt | label: label}

  @doc """
  Sets a description for the option (displayed when selected/hovered).
  """
  def description(opt, desc), do: %{opt | description: desc}

  @doc """
  Sets whether the option is initially selected (default: `true`).
  """
  def selected(opt, sel \\ true), do: %{opt | selected: sel}
end
