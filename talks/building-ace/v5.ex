opts = [:binary, {:reuseaddr, true}, {:active, false}]
{:ok, socket} = :gen_tcp.listen(8080, opts)

for _ <- 1..100_000 do
  spawn_link(fn() ->
    {:ok, connection} = :gen_tcp.accept(socket)

    {:ok, message} = :gen_tcp.recv(connection, 0)
    case message do
      "CRASH" <> _ ->
        exit(:crash)
      _ ->
        :ok = :gen_tcp.send(connection, message)
    end
  end)
end
Process.flag(:trap_exit, true)
receive do
  message ->
    IO.inspect(message)
end
:timer.sleep(:infinity)
