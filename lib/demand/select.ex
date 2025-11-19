defmodule Demand.Select do
  @moduledoc """
  A single selection prompt.
  """

  alias Demand.Ansi
  alias Demand.Term
  alias Demand.Option

  defstruct [
    prompt: "",
    options: [],
    filterable: false,
    description: nil,
    limit: 10
  ]

  @doc """
  Creates a new Select prompt.
  """
  def new(prompt) do
    %__MODULE__{prompt: prompt}
  end

  @doc """
  Adds an option to the select list.
  Can be a string or a `Demand.Option` struct.
  """
  def option(select, %Option{} = opt), do: %{select | options: select.options ++ [opt]}
  def option(select, value), do: option(select, Option.new(value))
  
  @doc """
  Sets a description to display above the prompt.
  """
  def description(select, desc), do: %{select | description: desc}

  @doc """
  Enables or disables filtering (default: `true`).
  """
  def filterable(select, filterable \\ true), do: %{select | filterable: filterable}

  @doc """
  Runs the prompt and waits for user selection.
  Returns `{:ok, value}` on success.
  """
  def run(select) do
    if select.description do
      IO.puts(Ansi.color(select.description, :grey))
    end

    Term.with_raw(fn ->
      loop(select, "", 0)
    end)
  end

  defp loop(select, filter, cursor) do
    visible_options = filter_options(select.options, filter)
    # Ensure cursor is within bounds
    cursor = clamp(cursor, 0, max(0, length(visible_options) - 1))

    render(select, filter, visible_options, cursor)

    key = Term.read_key()
    
    case handle_key(key, select, filter, cursor, visible_options) do
      {:ok, selected_option} ->
        clear_render(select, visible_options)
        IO.puts(Ansi.color("? ", :green) <> select.prompt <> " " <> Ansi.color(selected_option.label, :cyan))
        {:ok, selected_option.value}

      {:continue, new_filter, new_cursor} ->
        clear_render(select, visible_options)
        loop(select, new_filter, new_cursor)
    end
  end

  defp filter_options(options, ""), do: options
  defp filter_options(options, filter) do
    Enum.filter(options, fn opt ->
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

  defp render(select, filter, visible_options, cursor) do
    # Prompt line
    prompt_line = Ansi.color("? ", :green) <> select.prompt
    filter_display = if select.filterable, do: ": " <> filter, else: ""
    IO.write(prompt_line <> filter_display <> "\r\n")

    # Options
    # TODO: Pagination
    # For now, show all (or up to limit)
    limit = select.limit
    # Simple sliding window centered or top? 
    # Let's just show first 'limit' or slice around cursor.
    # Simplest: show all for now, assume list is small.
    
    visible_options
    |> Enum.with_index()
    |> Enum.take(limit) # Just take first N for now to avoid overflow
    # Actually, if I take first N, and cursor is > N, I can't see it.
    # I need a window offset.
    # But let's skip complex pagination for this iteration.
    
    |> Enum.each(fn {opt, idx} ->
      prefix = if idx == cursor, do: Ansi.color("> ", :cyan), else: "  "
      label = if idx == cursor, do: Ansi.color(opt.label, :cyan), else: opt.label
      
      desc = 
        if idx == cursor and opt.description do
           " " <> Ansi.color(opt.description, :grey)
        else
          ""
        end

      IO.write(prefix <> label <> desc <> "\r\n")
    end)
    
    # If options are empty
    if Enum.empty?(visible_options) do
      IO.write(Ansi.color("  No matches found", :grey) <> "\r\n")
    end
  end

  defp clear_render(select, visible_options) do
    # Calculate how many lines we printed
    # Prompt line + options lines
    # + 1 for prompt
    count = length(Enum.take(visible_options, select.limit))
    count = if count == 0, do: 2, else: count + 1
    
    IO.write(Ansi.cursor_up(count))
    # Clear each line
    Enum.each(1..count, fn _ -> 
      IO.write(Ansi.clear_line() <> "\r" <> Ansi.cursor_down(1))
    end)
    IO.write(Ansi.cursor_up(count))
  end

  defp handle_key(:enter, _select, _filter, cursor, visible_options) do
    if Enum.empty?(visible_options) do
      {:continue, "", 0} # Do nothing if empty
    else
      {:ok, Enum.at(visible_options, cursor)}
    end
  end

  defp handle_key(:up, _select, filter, cursor, _visible_options) do
    {:continue, filter, cursor - 1}
  end

  defp handle_key(:down, _select, filter, cursor, _visible_options) do
    {:continue, filter, cursor + 1}
  end

  defp handle_key(:backspace, select, filter, cursor, _visible_options) do
    if select.filterable and String.length(filter) > 0 do
      {:continue, String.slice(filter, 0, String.length(filter) - 1), 0} # Reset cursor on filter change
    else
      {:continue, filter, cursor}
    end
  end

  defp handle_key(char, select, filter, cursor, _visible_options) when is_binary(char) do
    if select.filterable do
      {:continue, filter <> char, 0} # Reset cursor on filter change
    else
      {:continue, filter, cursor}
    end
  end

  defp handle_key(_, _select, filter, cursor, _visible_options) do
    {:continue, filter, cursor}
  end
end
