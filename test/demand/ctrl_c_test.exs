defmodule Demand.CtrlCTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Demand.{Input, Select, MultiSelect, Confirm, Dialog, List}

  test "Input handles Ctrl+C" do
    input = Input.new("Name")
    capture_io([input: "\x03", capture_prompt: true], fn ->
      assert {:error, :interrupted} = Input.run(input)
    end)
  end

  test "Select handles Ctrl+C" do
    select = Select.new("Color") |> Select.option("Red")
    capture_io([input: "\x03", capture_prompt: true], fn ->
      assert {:error, :interrupted} = Select.run(select)
    end)
  end

  test "MultiSelect handles Ctrl+C" do
    select = MultiSelect.new("Toppings") |> MultiSelect.option("Cheese")
    capture_io([input: "\x03", capture_prompt: true], fn ->
      assert {:error, :interrupted} = MultiSelect.run(select)
    end)
  end

  test "Confirm handles Ctrl+C" do
    confirm = Confirm.new("Sure?")
    capture_io([input: "\x03", capture_prompt: true], fn ->
      assert {:error, :interrupted} = Confirm.run(confirm)
    end)
  end

  test "Dialog handles Ctrl+C" do
    dialog = Dialog.new("Title") |> Dialog.buttons(["Yes", "No"])
    capture_io([input: "\x03", capture_prompt: true], fn ->
      assert {:error, :interrupted} = Dialog.run(dialog)
    end)
  end

  test "List handles Ctrl+C" do
    list = List.new("Items") |> List.item("Item 1")
    capture_io([input: "\x03", capture_prompt: true], fn ->
      assert {:error, :interrupted} = List.run(list)
    end)
  end

  test "Input handles Ctrl+\\ (SIGQUIT)" do
    input = Input.new("Name")
    capture_io([input: "\x1c", capture_prompt: true], fn ->
      assert {:error, :interrupted} = Input.run(input)
    end)
  end
end
