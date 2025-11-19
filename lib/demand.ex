defmodule Demand do
  @moduledoc """
  Demand: A prompt library for Elixir.
  """

  alias Demand.Input
  alias Demand.Select
  alias Demand.MultiSelect
  alias Demand.Confirm
  alias Demand.Spinner

  alias Demand.Dialog
  alias Demand.List

  @doc """
  Creates a new Input prompt.
  """
  def input(prompt), do: Input.new(prompt)

  @doc """
  Creates a new Select prompt.
  """
  def select(prompt), do: Select.new(prompt)

  @doc """
  Creates a new MultiSelect prompt.
  """
  def multi_select(prompt), do: MultiSelect.new(prompt)

  @doc """
  Creates a new Confirm prompt.
  """
  def confirm(prompt), do: Confirm.new(prompt)

  @doc """
  Creates a new Spinner.
  """
  def spinner(text), do: Spinner.new(text)

  @doc """
  Creates a new Dialog.
  """
  def dialog(title), do: Dialog.new(title)

  @doc """
  Creates a new List.
  """
  def list(title), do: List.new(title)
end
