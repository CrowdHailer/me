opts = [:binary, {:reuseaddr, true}, {:active, false}]
{:ok, socket} = :gen_tcp.listen(8080, opts)

for i <- 1..10 do
  spawn(fn() ->
    if rem(i, 2) == 0 do
      1 / 0
    end
    {:ok, connection} = :gen_tcp.accept(socket)

    {:ok, message} = :gen_tcp.recv(connection, 0)
    :ok = :gen_tcp.send(connection, message)
  end)
end
:timer.sleep(:infinity)
