alias Demand.Spinner

Spinner.new("Loading Data...")
|> Spinner.run(fn ->
  :timer.sleep(2000)
  "Data loaded"
end)
|> IO.puts()
