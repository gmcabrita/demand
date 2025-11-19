defmodule Demand.Spinner do
  alias Demand.Ansi

  defstruct [
    text: "",
    frames: ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"],
    interval: 100
  ]

  def new(text), do: %__MODULE__{text: text}

  def run(spinner, fun) do
    # Hide cursor
    IO.write(Ansi.cursor_hide())
    
    spinner_pid = spawn_link(fn -> loop(spinner, 0) end)
    
    try do
      result = fun.()
      send(spinner_pid, {:stop, self()})
      receive do
        :stopped -> :ok
      end
      result
    after
      # Ensure cursor is shown even on crash
      IO.write(Ansi.cursor_show())
    end
  end

  defp loop(spinner, idx) do
    frame = Enum.at(spinner.frames, rem(idx, length(spinner.frames)))
    IO.write("\r" <> Ansi.color(frame, :cyan) <> " " <> spinner.text)
    
    receive do
      {:stop, caller} -> 
        IO.write("\r" <> Ansi.clear_line() <> Ansi.color("✓", :green) <> " " <> spinner.text <> "\r\n")
        send(caller, :stopped)
    after
      spinner.interval -> loop(spinner, idx + 1)
    end
  end
end
