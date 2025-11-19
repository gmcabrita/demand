defmodule Demand do
  @moduledoc """
  Demand is a library for creating interactive console prompts in Elixir.
  It is inspired by the Rust library `demand` (which in turn is inspired by Go's `huh`).
  
  It provides several types of prompts:
  * `Input` - Single line text input
  * `Select` - Single selection from a list
  * `MultiSelect` - Multiple selection from a list
  * `Confirm` - Yes/No confirmation
  * `Spinner` - Loading spinner
  * `Dialog` - Dialog with buttons
  * `List` - Simple list view
  """

  alias Demand.Input
  alias Demand.Select
  alias Demand.MultiSelect
  alias Demand.Confirm
  alias Demand.Spinner

  alias Demand.Dialog
  alias Demand.List

  @doc """
  Creates a new `Demand.Input` prompt.
  
  ## Example
      Demand.input("What is your name?")
      |> Demand.Input.run()
  """
  def input(prompt), do: Input.new(prompt)

  @doc """
  Creates a new `Demand.Select` prompt.

  ## Example
      Demand.select("Choose a color")
      |> Demand.Select.option("Red")
      |> Demand.Select.option("Blue")
      |> Demand.Select.run()
  """
  def select(prompt), do: Select.new(prompt)

  @doc """
  Creates a new `Demand.MultiSelect` prompt.

  ## Example
      Demand.multi_select("Choose toppings")
      |> Demand.MultiSelect.option("Cheese")
      |> Demand.MultiSelect.option("Pepperoni")
      |> Demand.MultiSelect.run()
  """
  def multi_select(prompt), do: MultiSelect.new(prompt)

  @doc """
  Creates a new `Demand.Confirm` prompt.

  ## Example
      Demand.confirm("Are you sure?")
      |> Demand.Confirm.run()
  """
  def confirm(prompt), do: Confirm.new(prompt)

  @doc """
  Creates a new `Demand.Spinner`.

  ## Example
      Demand.spinner("Loading...")
      |> Demand.Spinner.run(fn -> :timer.sleep(1000) end)
  """
  def spinner(text), do: Spinner.new(text)

  @doc """
  Creates a new `Demand.Dialog`.

  ## Example
      Demand.dialog("Alert")
      |> Demand.Dialog.buttons(["OK", "Cancel"])
      |> Demand.Dialog.run()
  """
  def dialog(title), do: Dialog.new(title)

  @doc """
  Creates a new `Demand.List`.

  ## Example
      Demand.list("Items")
      |> Demand.List.item("Item A")
      |> Demand.List.item("Item B")
      |> Demand.List.run()
  """
  def list(title), do: List.new(title)
end
