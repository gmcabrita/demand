alias Demand.Input

notempty_minlen = fn s ->
  cond do
    s == "" -> {:error, "Name cannot be empty"}
    String.length(s) < 8 -> {:error, "Name must be at least 8 characters"}
    true -> :ok
  end
end

t = Input.new("What's your name?")
    |> Input.description("We'll use this to personalize your experience.")
    |> Input.placeholder("Enter your name")
    |> Input.suggestions([
        "Adam Grant",
        "Danielle Steel",
        "Eveline Widmer-Schlumpf",
        "Robert De Niro",
        "Ronaldo Rodrigues de Jesus",
        "Sarah Michelle Gellar",
        "Yael Naim",
        "Zack Snyder",
    ])
    |> Input.validation(notempty_minlen)

case Demand.Input.run(t) do
  {:ok, name} -> IO.puts("Hello, #{name}!")
  _ -> IO.puts("Error or aborted")
end
