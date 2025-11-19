defmodule Demand.Term do
  @moduledoc """
  Terminal handling (Raw mode and input reading).
  """

  def with_raw(fun) do
    tmp_file = Path.join(System.tmp_dir!(), "demand_stty_#{System.unique_integer([:positive])}")

    # Save settings
    # We use :nouse_stdio to ensure stty inherits stdin from the BEAM process (the TTY)
    # and we redirect output to a file to capture the settings string.
    # We redirect stderr to /dev/null to avoid noise when not running in a TTY (e.g. tests)
    if run_port_cmd("stty -g > '#{tmp_file}' 2>/dev/null") == 0 do
      initial_settings = File.read!(tmp_file) |> String.trim()

      # Set raw mode
      run_port_cmd("stty raw -echo 2>/dev/null")

      try do
        fun.()
      after
        # Restore settings
        run_port_cmd("stty #{initial_settings} 2>/dev/null")
        File.rm(tmp_file)
      end
    else
      IO.puts(Demand.Ansi.color("Warning: Could not access TTY (stty failed). Input may not work as expected.", :yellow))
      # Try to cleanup just in case
      File.rm(tmp_file)
      fun.()
    end
  end

  defp run_port_cmd(command) do
    port = Port.open({:spawn, "sh -c \"#{command}\""}, [:nouse_stdio, :exit_status])
    
    receive do
      {^port, {:exit_status, status}} -> status
    end
  end

  def read_key do
    case IO.getn("", 1) do
      "\e" -> read_escape_sequence()
      "\r" -> :enter
      "\n" -> :enter
      "\t" -> :tab
      "\x7f" -> :backspace
      char -> char
    end
  end

  defp read_escape_sequence do
    # Read next chars to determine sequence
    case IO.getn("", 2) do
      "[A" -> :up
      "[B" -> :down
      "[C" -> :right
      "[D" -> :left
      _ -> :esc
    end
  end
end
