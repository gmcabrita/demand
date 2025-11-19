defmodule Demand.MultiSelect do
  alias Demand.Ansi
  alias Demand.Term
  alias Demand.Option

  defstruct [
    prompt: "",
    options: [],
    filterable: false,
    description: nil,
    min_selected: 0,
    max_selected: nil,
    limit: 10
  ]

  def new(prompt) do
    %__MODULE__{prompt: prompt}
  end

  def option(select, %Option{} = opt), do: %{select | options: select.options ++ [opt]}
  def option(select, value), do: option(select, Option.new(value))
  
  def description(select, desc), do: %{select | description: desc}
  def filterable(select, filterable \\ true), do: %{select | filterable: filterable}
  def min_selected(select, min), do: %{select | min_selected: min}
  def max_selected(select, max), do: %{select | max_selected: max}

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
    cursor = clamp(cursor, 0, max(0, length(visible_options) - 1))

    render(select, filter, visible_options, cursor)

    key = Term.read_key()
    
    case handle_key(key, select, filter, cursor, visible_options) do
      {:ok, final_options} ->
        selected_values = 
          final_options
          |> Enum.filter(& &1.selected)
          |> Enum.map(& &1.value)

        clear_render(select, visible_options)
        IO.puts(Ansi.color("? ", :green) <> select.prompt <> " " <> Ansi.color("#{length(selected_values)} selected", :cyan))
        {:ok, selected_values}

      {:continue, new_select, new_filter, new_cursor} ->
        clear_render(select, visible_options)
        loop(new_select, new_filter, new_cursor)
        
      {:error, _msg} ->
         # Show error? For now just ignore invalid confirms
         clear_render(select, visible_options)
         # Could show error transiently
         loop(select, filter, cursor)
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
    prompt_line = Ansi.color("? ", :green) <> select.prompt
    filter_display = if select.filterable, do: ": " <> filter, else: ""
    IO.write(prompt_line <> filter_display <> "\r\n")

    limit = select.limit
    visible_options
    |> Enum.with_index()
    |> Enum.take(limit)
    |> Enum.each(fn {opt, idx} ->
      cursor_prefix = if idx == cursor, do: Ansi.color(">", :cyan), else: " "
      checkbox = if opt.selected, do: Ansi.color("[x]", :green), else: "[ ]"
      label = if idx == cursor, do: Ansi.color(opt.label, :cyan), else: opt.label
      
      IO.write("#{cursor_prefix} #{checkbox} #{label}\r\n")
    end)
    
    if Enum.empty?(visible_options) do
      IO.write(Ansi.color("  No matches found", :grey) <> "\r\n")
    end
  end

  defp clear_render(select, visible_options) do
    count = length(Enum.take(visible_options, select.limit))
    count = if count == 0, do: 2, else: count + 1
    
    IO.write(Ansi.cursor_up(count))
    Enum.each(1..count, fn _ -> 
      IO.write(Ansi.clear_line() <> "\r" <> Ansi.cursor_down(1))
    end)
    IO.write(Ansi.cursor_up(count))
  end

  defp handle_key(:enter, select, _filter, _cursor, _visible_options) do
    selected_count = Enum.count(select.options, & &1.selected)
    
    cond do
      select.min_selected > 0 and selected_count < select.min_selected ->
        {:error, "Select at least #{select.min_selected}"}
      select.max_selected != nil and selected_count > select.max_selected ->
        {:error, "Select at most #{select.max_selected}"}
      true ->
        {:ok, select.options}
    end
  end

  defp handle_key(:up, select, filter, cursor, _visible_options) do
    {:continue, select, filter, cursor - 1}
  end

  defp handle_key(:down, select, filter, cursor, _visible_options) do
    {:continue, select, filter, cursor + 1}
  end

  defp handle_key(" ", select, filter, cursor, visible_options) do
    if Enum.empty?(visible_options) do
      {:continue, select, filter, cursor}
    else
      target_opt = Enum.at(visible_options, cursor)
      
      # Toggle selection in the main options list
      new_options = Enum.map(select.options, fn opt ->
        if opt.value == target_opt.value do
          %{opt | selected: not opt.selected}
        else
          opt
        end
      end)
      
      new_select = %{select | options: new_options}
      {:continue, new_select, filter, cursor}
    end
  end

  defp handle_key(:backspace, select, filter, cursor, _visible_options) do
    if select.filterable and String.length(filter) > 0 do
      {:continue, select, String.slice(filter, 0, String.length(filter) - 1), 0}
    else
      {:continue, select, filter, cursor}
    end
  end

  defp handle_key(char, select, filter, cursor, _visible_options) when is_binary(char) do
    if select.filterable do
      {:continue, select, filter <> char, 0}
    else
      {:continue, select, filter, cursor}
    end
  end

  defp handle_key(_, select, filter, cursor, _visible_options) do
    {:continue, select, filter, cursor}
  end
end
