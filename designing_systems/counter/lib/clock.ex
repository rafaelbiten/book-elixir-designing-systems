defmodule Clock do
  @moduledoc """
  Simple module to test the use of the Counter.Core module.
  """

  # Usage:
  # iex> Clock.start(fn(tick) -> IO.puts "Ticking #{tick}" end)

  def start(f) do
    run(f, 0)
  end

  def run(function, count) do
    function.(count)
    new_count = Counter.Core.inc(count)
    :timer.sleep(1000)
    run(function, new_count)
  end
end
