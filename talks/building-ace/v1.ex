opts = [:binary, {:reuseaddr, true}, {:active, false}]

{:ok, socket} = :gen_tcp.listen(8080, opts)
{:ok, connection} = :gen_tcp.accept(socket)

{:ok, message} = :gen_tcp.recv(connection, 0)
:ok = :gen_tcp.send(connection, message)
