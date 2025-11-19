defmodule Demand.List do
  @moduledoc """
  A simple list selection prompt (scrollable).
  """

  alias Demand.Ansi
  alias Demand.Term
  alias Demand.Option

  defstruct [
    title: "",
    items: [],
    filterable: false,
    description: nil,
    limit: 10
  ]

  @doc """
  Creates a new List prompt.
  """
  def new(title) do
    %__MODULE__{title: title}
  end

  @doc """
  Adds an item to the list.
  """
  def item(list, value) when is_binary(value) do
    %{list | items: list.items ++ [Option.new(value)]}
  end

  def item(list, %Option{} = opt) do
    %{list | items: list.items ++ [opt]}
  end
  
  @doc """
  Sets a description to display above the prompt.
  """
  def description(list, desc), do: %{list | description: desc}

  @doc """
  Enables or disables filtering (default: `true`).
  """
  def filterable(list, filterable \\ true), do: %{list | filterable: filterable}

  @doc """
  Runs the prompt and waits for user selection.
  Returns `{:ok, value}` on success.
  """
  def run(list) do
    if list.description do
      IO.puts(Ansi.color(list.description, :grey))
    end

    Term.with_raw(fn ->
      loop(list, "", 0)
    end)
  end

  defp loop(list, filter, cursor) do
    visible_items = filter_items(list.items, filter)
    cursor = clamp(cursor, 0, max(0, length(visible_items) - 1))

    render(list, filter, visible_items, cursor)

    key = Term.read_key()
    
    case handle_key(key, list, filter, cursor, visible_items) do
      {:ok, selected_item} ->
        clear_render(list, visible_items)
        # List usually just finishes? 
        # Or should we print what was selected?
        # Select prints "? Title > Value"
        # List might just exit.
        {:ok, selected_item.value}

      {:error, :interrupted} ->
        clear_render(list, visible_items)
        {:error, :interrupted}

      {:continue, new_filter, new_cursor} ->
        clear_render(list, visible_items)
        loop(list, new_filter, new_cursor)
    end
  end

  defp filter_items(items, ""), do: items
  defp filter_items(items, filter) do
    Enum.filter(items, fn opt ->
      String.contains?(String.downcase(opt.label), String.downcase(filter))
    end)
  end

  defp clamp(val, min, max) do
    cond do
      val < min -> min
      val > max -> max
      true -> val
    end
  end

  defp render(list, filter, visible_items, cursor) do
    title_line = Ansi.color(list.title, :magenta) # Maybe different color for List title?
    filter_display = if list.filterable and filter != "", do: ": " <> filter, else: ""
    IO.write(title_line <> filter_display <> "\r\n")

    limit = list.limit
    # Simple pagination (sliding window) could be added here but skipping for consistency with Select for now.
    
    visible_items
    |> Enum.with_index()
    |> Enum.take(limit)
    |> Enum.each(fn {opt, idx} ->
      # For List, maybe we don't use ">" but just highlight the line?
      # Or maybe ">" is fine.
      prefix = if idx == cursor, do: Ansi.color("> ", :cyan), else: "  "
      label = if idx == cursor, do: Ansi.color(opt.label, :cyan), else: opt.label
      
      IO.write(prefix <> label <> "\r\n")
    end)
    
    if Enum.empty?(visible_items) do
      IO.write(Ansi.color("  No items found", :grey) <> "\r\n")
    end
  end

  defp clear_render(list, visible_items) do
    count = length(Enum.take(visible_items, list.limit))
    count = if count == 0, do: 2, else: count + 1
    
    IO.write(Ansi.cursor_up(count))
    Enum.each(1..count, fn _ -> 
      IO.write(Ansi.clear_line() <> "\r" <> Ansi.cursor_down(1))
    end)
    IO.write(Ansi.cursor_up(count))
  end

  defp handle_key(:ctrl_c, _list, _filter, _cursor, _visible_items) do
    {:error, :interrupted}
  end

  defp handle_key(:enter, _list, _filter, cursor, visible_items) do
    if Enum.empty?(visible_items) do
      {:continue, "", 0}
    else
      {:ok, Enum.at(visible_items, cursor)}
    end
  end

  defp handle_key(:up, _list, filter, cursor, _visible_items) do
    {:continue, filter, cursor - 1}
  end

  defp handle_key(:down, _list, filter, cursor, _visible_items) do
    {:continue, filter, cursor + 1}
  end

  defp handle_key(:backspace, list, filter, cursor, _visible_items) do
    if list.filterable and String.length(filter) > 0 do
      {:continue, String.slice(filter, 0, String.length(filter) - 1), 0}
    else
      {:continue, filter, cursor}
    end
  end

  defp handle_key(char, list, filter, cursor, _visible_items) when is_binary(char) do
    if list.filterable do
      {:continue, filter <> char, 0}
    else
      {:continue, filter, cursor}
    end
  end

  defp handle_key(_, _list, filter, cursor, _visible_items) do
    {:continue, filter, cursor}
  end
end
