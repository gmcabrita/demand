# Demand

A prompt library for Elixir. Port of [demand](https://github.com/jdx/demand) for Rust.

## Installation

Add `demand` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:demand, "~> 0.1.0"}
  ]
end
```

## Usage

Check the `examples/` directory for runnable examples.

### Input

```elixir
alias Demand.Input

Input.new("What's your name?")
|> Input.run()
```

### Select

```elixir
alias Demand.Select

Select.new("Choose a color")
|> Select.option("Red")
|> Select.option("Blue")
|> Select.option("Green")
|> Select.run()
```

### MultiSelect

```elixir
alias Demand.MultiSelect

MultiSelect.new("Choose toppings")
|> MultiSelect.option("Cheese")
|> MultiSelect.option("Pepperoni")
|> MultiSelect.option("Mushrooms")
|> MultiSelect.run()
```

### Confirm

```elixir
alias Demand.Confirm

Confirm.new("Are you sure?")
|> Confirm.run()
```

### Dialog

```elixir
alias Demand.Dialog

Dialog.new("Are you sure?")
|> Dialog.buttons(["Yes", "No"])
|> Dialog.run()
```

### List

```elixir
alias Demand.List

List.new("Items")
|> List.item("Item 1")
|> List.item("Item 2")
|> List.run()
```

### Spinner

```elixir
alias Demand.Spinner

Spinner.new("Loading...")
|> Spinner.run(fn -> :timer.sleep(1000) end)
```
