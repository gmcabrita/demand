defmodule Demand.Dialog do
  alias Demand.Ansi
  alias Demand.Term

  defstruct [
    title: "",
    description: nil,
    buttons: [],
    selected_button: 0
  ]

  def new(title) do
    %__MODULE__{title: title}
  end

  def description(dialog, desc), do: %{dialog | description: desc}
  
  def buttons(dialog, buttons) when is_list(buttons) do
    %{dialog | buttons: buttons}
  end

  def selected_button(dialog, idx), do: %{dialog | selected_button: idx}

  def run(dialog) do
    if dialog.description do
      IO.puts(Ansi.color(dialog.description, :grey))
    end

    Term.with_raw(fn ->
      loop(dialog, dialog.selected_button)
    end)
  end

  defp loop(dialog, current_idx) do
    render(dialog, current_idx)

    key = Term.read_key()
    
    case handle_key(key, dialog, current_idx) do
      {:ok, result} ->
        IO.write("\r" <> Ansi.clear_line())
        IO.puts(Ansi.color("? ", :green) <> dialog.title <> " " <> Ansi.color(result, :cyan))
        {:ok, result}

      {:continue, new_idx} ->
        IO.write("\r" <> Ansi.clear_line())
        loop(dialog, new_idx)
    end
  end

  defp render(dialog, current_idx) do
    prompt = Ansi.color("? ", :green) <> dialog.title <> " "
    
    buttons_str = 
      dialog.buttons
      |> Enum.with_index()
      |> Enum.map(fn {btn, idx} ->
        label = if is_binary(btn), do: btn, else: btn.label
        
        if idx == current_idx do
           Ansi.color(label, :cyan)
        else
           Ansi.color(label, :grey)
        end
      end)
      |> Enum.join(" / ") 
      
    IO.write(prompt <> buttons_str)
  end

  defp handle_key(:enter, dialog, current_idx) do
    btn = Enum.at(dialog.buttons, current_idx)
    val = if is_binary(btn), do: btn, else: btn.value
    {:ok, val}
  end

  defp handle_key(:left, _dialog, current_idx) do
    {:continue, max(0, current_idx - 1)}
  end

  defp handle_key("h", _dialog, current_idx) do
    {:continue, max(0, current_idx - 1)}
  end

  defp handle_key(:right, dialog, current_idx) do
    {:continue, min(length(dialog.buttons) - 1, current_idx + 1)}
  end
  
  defp handle_key("l", dialog, current_idx) do
    {:continue, min(length(dialog.buttons) - 1, current_idx + 1)}
  end

  defp handle_key(:tab, dialog, current_idx) do
     new_idx = rem(current_idx + 1, length(dialog.buttons))
     {:continue, new_idx}
  end

  defp handle_key(_, _dialog, current_idx), do: {:continue, current_idx}
end
