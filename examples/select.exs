alias Demand.Select
alias Demand.Option

Select.new("Toppings")
|> Select.description("Select your topping")
|> Select.filterable(true)
|> Select.option(Option.new("Lettuce") |> Option.description("Fresh and crispy"))
|> Select.option(Option.new("Tomatoes") |> Option.description("Juicy and red"))
|> Select.option(Option.new("Charm Sauce") |> Option.description("Our secret recipe"))
|> Select.option(Option.new("Jalapenos") |> Option.label("Jalapeños") |> Option.description("Spicy and hot"))
|> Select.option(Option.new("Cheese") |> Option.description("Melted and gooey"))
|> Select.option(Option.new("Vegan Cheese") |> Option.description("Melted and gooey"))
|> Select.option(Option.new("Nutella") |> Option.description("Sweet and creamy"))
|> Select.run()
|> case do
  {:ok, choice} -> IO.puts("You chose: #{choice}")
  _ -> IO.puts("Aborted")
end
