defmodule Counter do
  @moduledoc """
  Counter public API
  """

  # Usage:
  # iex> pid = Counter.start(0)
  # iex> Counter.tick(pid)
  # iex> Counter.tick(pid)
  # iex> Counter.tick(pid)
  # iex> Counter.state(pid) // 3

  def start(initial_count) do
    spawn(fn -> Counter.Server.run(initial_count) end)
  end

  def tick(pid) do
    send(pid, {:tick, self()})
  end

  def state(pid) do
    send(pid, {:state, self()})

    receive do
      {:count, value} -> value
    end
  end
end
