opts = [:binary, {:reuseaddr, true}, {:active, false}]

{:ok, socket} = :gen_tcp.listen(8080, opts)

for i <- 1..100_000 do
  spawn(fn() ->
    {:ok, connection} = :gen_tcp.accept(socket)

    {:ok, message} = :gen_tcp.recv(connection, 0)
    :ok = :gen_tcp.send(connection, message)
  end)
end

for max <- 1..100_000 do
  spawn(fn() ->
    for j <- Stream.cycle(1..max) do
      IO.puts(j)
    end
  end)
end
:timer.sleep(:infinity)
