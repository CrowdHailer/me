:erlang.process_info(self())
|> IO.inspect

# Start with 4
# end with cycle
for i <- 1..1_000_000 do
  spawn(fn() ->
    opts = [:binary, {:reuseaddr, true}, {:active, false}]

    {:ok, socket} = :gen_tcp.listen(8080, opts)
    {:ok, connection} = :gen_tcp.accept(socket)

    {:ok, message} = :gen_tcp.recv(connection, 0)
    :ok = :gen_tcp.send(connection, message)
  end)
end

# This is an error check 4


# for i <- 1..5 do
#   spawn(fn() ->
#     for j <- Stream.cycle([i]) do
#       # IO.inspect("#{j}")
#     end
#   end)
# end
:timer.sleep(:infinity)
