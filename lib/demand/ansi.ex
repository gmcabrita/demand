defmodule Demand.Ansi do
  @moduledoc """
  ANSI escape codes for terminal manipulation.
  """

  def clear_line, do: "\e[2K\r"
  def clear_screen, do: "\e[2J"
  def cursor_up(n \\ 1), do: "\e[#{n}A"
  def cursor_down(n \\ 1), do: "\e[#{n}B"
  def cursor_left(n \\ 1), do: "\e[#{n}D"
  def cursor_right(n \\ 1), do: "\e[#{n}C"
  def cursor_hide, do: "\e[?25l"
  def cursor_show, do: "\e[?25h"
  def save_cursor, do: "\e[s"
  def restore_cursor, do: "\e[u"

  def color(text, color) do
    [color_code(color), text, reset()]
    |> IO.iodata_to_binary()
  end

  defp color_code(:red), do: "\e[31m"
  defp color_code(:green), do: "\e[32m"
  defp color_code(:yellow), do: "\e[33m"
  defp color_code(:blue), do: "\e[34m"
  defp color_code(:magenta), do: "\e[35m"
  defp color_code(:cyan), do: "\e[36m"
  defp color_code(:white), do: "\e[37m"
  defp color_code(:black), do: "\e[30m"
  defp color_code(:grey), do: "\e[90m"
  defp color_code(_), do: "" # Default or unknown

  def reset, do: "\e[0m"
end
