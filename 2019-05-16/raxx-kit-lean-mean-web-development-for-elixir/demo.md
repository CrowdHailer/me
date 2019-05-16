DELETE cookies

Quite a lot of clean up

Delete homepage,
rename form field

Add Follow questions, to router

Add Server Sent Events

set_body!

If Raxx kit just creates a Get and Post

```elixir

defmodule Questions do
  @group :questions

  def ask(message) do
    :ok = :pg2.create(@group)
    for client <- :pg2.get_members(@group) do
      send(client, {@group, message})
    end

    {:ok, message}
  end

  def follow() do
    :ok = :pg2.create(@group)
    :ok = :pg2.join(@group, self())
    {:ok, @group}
  end
end
```
