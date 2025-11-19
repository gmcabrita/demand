defmodule Demand.Input do
  @moduledoc """
  A single-line text input prompt.
  """

  alias Demand.Ansi
  alias Demand.Term

  defstruct [
    message: "",
    prompt: "? ",
    placeholder: "",
    password: false,
    suggestions: [],
    validation: nil,
    description: nil
  ]

  @doc """
  Creates a new Input prompt with a message.
  """
  def new(message) do
    %__MODULE__{message: message}
  end

  @doc """
  Sets the prompt prefix (default: `"? "`).
  """
  def prompt(input, text), do: %{input | prompt: text}

  @doc """
  Sets the placeholder text to display when input is empty.
  """
  def placeholder(input, text), do: %{input | placeholder: text}

  @doc """
  Enables or disables password mode (masked input).
  """
  def password(input, is_password \\ true), do: %{input | password: is_password}

  @doc """
  Sets a list of suggestions for auto-completion.
  """
  def suggestions(input, suggestions), do: %{input | suggestions: suggestions}

  @doc """
  Sets a validation function.
  The function should receive the input string and return `:ok` or `{:error, "message"}`.
  """
  def validation(input, validation_fn), do: %{input | validation: validation_fn}

  @doc """
  Sets a description to display above the prompt.
  """
  def description(input, text), do: %{input | description: text}

  @doc """
  Runs the prompt and waits for user input.
  Returns `{:ok, value}` on success.
  """
  def run(input) do
    if input.description do
      IO.puts(Ansi.color(input.description, :grey))
    end

    Term.with_raw(fn ->
      loop(input, "", 0, nil)
    end)
  end

  defp loop(input, value, cursor_pos, error) do
    render(input, value, cursor_pos, error)
    
    key = Term.read_key()
    
    case handle_key(key, input, value, cursor_pos) do
      {:ok, new_value} -> 
        # Final cleanup
        IO.write("\r\n")
        {:ok, new_value}

      {:error, :interrupted} ->
        # Cleanup
        IO.write("\r\n")
        {:error, :interrupted}
      
      {:continue, new_value, new_cursor_pos, new_error} ->
        # If we had an error line, we need to clear it before re-rendering
        # But render handles clearing current line.
        # If error was present, we might have printed a newline. 
        # This is tricky. 
        # Let's simplify: Error is shown on the same line or we handle multiline clearing.
        
        # If we previously showed an error, we are on the error line?
        # No, we should restore cursor to input line.
        
        clean_lines(if error, do: 1, else: 0)
        loop(input, new_value, new_cursor_pos, new_error)
    end
  end

  defp clean_lines(0), do: IO.write("\r" <> Ansi.clear_line())
  defp clean_lines(n) do
    IO.write("\r" <> Ansi.clear_line())
    IO.write(Ansi.cursor_up(1))
    clean_lines(n - 1)
  end

  defp render(input, value, cursor_pos, error) do
    # Prompt
    prompt_str = Ansi.color(input.prompt, :green) <> Ansi.color(input.message, :white) <> " "
    
    # Value or Placeholder
    display_value = 
      if value == "" and input.placeholder != "" do
        Ansi.color(input.placeholder, :grey)
      else
        if input.password do
          String.duplicate("*", String.length(value))
        else
          value
        end
      end
    
    IO.write(prompt_str <> display_value)

    # Move cursor to correct position
    # Calculate visual length
    prompt_len = String.length(input.prompt) + String.length(input.message) + 1
    
    if value == "" and input.placeholder != "" do
      # Cursor at beginning
      IO.write("\r" <> Ansi.cursor_right(prompt_len))
    else
      # Cursor at cursor_pos
      IO.write("\r" <> Ansi.cursor_right(prompt_len + cursor_pos))
    end

    if error do
      IO.write("\n" <> Ansi.color("  " <> error, :red))
      # Move back up
      IO.write(Ansi.cursor_up(1))
      # Restore cursor column
      IO.write("\r" <> Ansi.cursor_right(prompt_len + cursor_pos))
    end
  end

  defp handle_key(:ctrl_c, _input, _value, _cursor_pos) do
    {:error, :interrupted}
  end

  defp handle_key(:enter, input, value, _cursor_pos) do
    case validate(input, value) do
      :ok -> {:ok, value}
      {:error, msg} -> {:continue, value, String.length(value), msg}
    end
  end

  defp handle_key(:backspace, _input, value, cursor_pos) do
    if cursor_pos > 0 do
      {left, right} = String.split_at(value, cursor_pos)
      new_left = String.slice(left, 0, String.length(left) - 1)
      new_value = new_left <> right
      {:continue, new_value, cursor_pos - 1, nil}
    else
      {:continue, value, cursor_pos, nil}
    end
  end

  defp handle_key(:left, _input, value, cursor_pos) do
    new_pos = max(0, cursor_pos - 1)
    {:continue, value, new_pos, nil}
  end

  defp handle_key(:right, _input, value, cursor_pos) do
    new_pos = min(String.length(value), cursor_pos + 1)
    {:continue, value, new_pos, nil}
  end
  
  defp handle_key(:tab, input, value, _cursor_pos) do
    # Simple completion: find first suggestion starting with value
    match = Enum.find(input.suggestions, fn s -> String.starts_with?(s, value) end)
    if match do
      {:continue, match, String.length(match), nil}
    else
      {:continue, value, String.length(value), nil}
    end
  end

  defp handle_key(char, _input, value, cursor_pos) when is_binary(char) do
    {left, right} = String.split_at(value, cursor_pos)
    new_value = left <> char <> right
    {:continue, new_value, cursor_pos + 1, nil}
  end

  defp handle_key(_, _input, value, cursor_pos) do
    {:continue, value, cursor_pos, nil}
  end

  defp validate(%{validation: nil}, _value), do: :ok
  defp validate(%{validation: fun}, value), do: fun.(value)
end
