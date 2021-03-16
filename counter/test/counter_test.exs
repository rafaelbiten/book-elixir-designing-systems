defmodule CounterTest do
  use ExUnit.Case
  doctest Counter

  test "inc incrementes an integer value by 1" do
    assert Counter.Core.inc(2) == 3
  end
end
