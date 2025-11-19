alias Demand.MultiSelect
alias Demand.Option

MultiSelect.new("Toppings")
|> MultiSelect.description("Select your toppings")
|> MultiSelect.min_selected(1)
|> MultiSelect.max_selected(4)
|> MultiSelect.filterable(true)
|> MultiSelect.option(Option.new("Lettuce") |> Option.selected(true))
|> MultiSelect.option(Option.new("Tomatoes") |> Option.selected(true))
|> MultiSelect.option(Option.new("Charm Sauce"))
|> MultiSelect.option(Option.new("Jalapenos") |> Option.label("Jalapeños"))
|> MultiSelect.option(Option.new("Cheese"))
|> MultiSelect.option(Option.new("Vegan Cheese"))
|> MultiSelect.option(Option.new("Nutella"))
|> MultiSelect.run()
|> case do
  {:ok, choices} -> IO.puts("You chose: #{Enum.join(choices, ", ")}")
  _ -> IO.puts("Aborted")
end
