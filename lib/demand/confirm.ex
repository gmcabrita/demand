defmodule Demand.Confirm do
  @moduledoc """
  A Yes/No confirmation prompt.
  """

  alias Demand.Ansi
  alias Demand.Term

  defstruct [
    prompt: "",
    affirmative: "Yes",
    negative: "No",
    default: true
  ]

  @doc """
  Creates a new Confirm prompt.
  """
  def new(prompt) do
    %__MODULE__{prompt: prompt}
  end

  @doc """
  Sets the text for the affirmative option (default: "Yes").
  """
  def affirmative(confirm, text), do: %{confirm | affirmative: text}

  @doc """
  Sets the text for the negative option (default: "No").
  """
  def negative(confirm, text), do: %{confirm | negative: text}

  @doc """
  Runs the prompt and waits for user confirmation.
  Returns `{:ok, true}` for affirmative, `{:ok, false}` for negative.
  """
  def run(confirm) do
    Term.with_raw(fn ->
      loop(confirm, confirm.default)
    end)
  end

  defp loop(confirm, current_choice) do
    render(confirm, current_choice)

    key = Term.read_key()
    
    case handle_key(key, confirm, current_choice) do
      {:ok, result} ->
        IO.write("\r" <> Ansi.clear_line())
        answer_text = if result, do: confirm.affirmative, else: confirm.negative
        IO.puts(Ansi.color("? ", :green) <> confirm.prompt <> " " <> Ansi.color(answer_text, :cyan))
        {:ok, result}

      {:error, :interrupted} ->
        IO.write("\r" <> Ansi.clear_line())
        {:error, :interrupted}

      {:continue, new_choice} ->
        IO.write("\r" <> Ansi.clear_line())
        loop(confirm, new_choice)
    end
  end

  defp render(confirm, current_choice) do
    prompt = Ansi.color("? ", :green) <> confirm.prompt <> " "
    
    yes_style = if current_choice, do: :cyan, else: :grey
    no_style = if !current_choice, do: :cyan, else: :grey
    
    yes_text = if current_choice, do: Ansi.color(confirm.affirmative, yes_style), else: confirm.affirmative
    no_text = if !current_choice, do: Ansi.color(confirm.negative, no_style), else: confirm.negative
    
    # Maybe highlight logic is simpler: bracket selected
    # Or just color selected.
    # Rust demand styles it as `Yes / No` with one bold/colored.
    
    IO.write(prompt <> yes_text <> " / " <> no_text)
  end

  defp handle_key(:ctrl_c, _confirm, _choice), do: {:error, :interrupted}
  defp handle_key(:enter, _confirm, current_choice), do: {:ok, current_choice}
  defp handle_key("y", _confirm, _), do: {:ok, true}
  defp handle_key("n", _confirm, _), do: {:ok, false}
  defp handle_key(:left, _confirm, _), do: {:continue, true}
  defp handle_key(:right, _confirm, _), do: {:continue, false}
  defp handle_key("h", _confirm, _), do: {:continue, true} # vim style
  defp handle_key("l", _confirm, _), do: {:continue, false} # vim style
  defp handle_key(:tab, _confirm, choice), do: {:continue, not choice}
  defp handle_key(_, _confirm, choice), do: {:continue, choice}
end
