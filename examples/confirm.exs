alias Demand.Confirm

Confirm.new("Are you sure?")
|> Confirm.affirmative("Yes!")
|> Confirm.negative("No.")
|> Confirm.run()
|> case do
  {:ok, true} -> IO.puts("Confirmed!")
  {:ok, false} -> IO.puts("Denied.")
  _ -> IO.puts("Aborted")
end
