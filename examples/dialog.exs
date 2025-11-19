alias Demand.Dialog
alias Demand.DialogButton

Dialog.new("Are you sure?")
|> Dialog.description("This will do a thing.")
|> Dialog.buttons([
    DialogButton.new("Ok"),
    DialogButton.new("Not sure"),
    DialogButton.new("Cancel")
])
|> Dialog.selected_button(1)
|> Dialog.run()
|> case do
  {:ok, value} -> IO.puts("You chose: #{value}")
  _ -> IO.puts("Aborted")
end
