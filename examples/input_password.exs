alias Demand.Input

Input.new("Set a password")
|> Input.placeholder("Enter password")
|> Input.prompt("Password: ")
|> Input.password(true)
|> Input.run()
|> case do
  {:ok, password} -> IO.puts("\nPassword set to: #{password}")
  _ -> IO.puts("\nAborted")
end
