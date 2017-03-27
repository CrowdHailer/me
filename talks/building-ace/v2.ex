spawn(fn() ->
  opts = [:binary, {:reuseaddr, true}, {:active, false}]

  {:ok, socket} = :gen_tcp.listen(8080, opts)
  {:ok, connection} = :gen_tcp.accept(socket)

  {:ok, message} = :gen_tcp.recv(connection, 0)
  :ok = :gen_tcp.send(connection, message)
end)

endless_stream = Stream.cycle([1, 2, 3, 4, 5])
Enum.each(endless_stream, fn(value) ->
  IO.puts(value)
end)
