defmodule EchoServer do
  def listen(port) do
    opts = [:binary, {:reuseaddr, true}, {:active, false}]
    :gen_tcp.listen(8080, opts)
  end

  def serve(socket) do
    {:ok, connection} = :gen_tcp.accept(socket)
    {:ok, message} = :gen_tcp.recv(connection, 0)
    :ok = :gen_tcp.send(connection, message)
  end
end
