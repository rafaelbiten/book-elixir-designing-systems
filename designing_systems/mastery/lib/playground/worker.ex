defmodule Playground.Worker do
  def take10() do
    IO.puts("Report partial success:")

    stream_work()
    |> Enum.take(10)
    |> IO.inspect()
  end

  def halt_on_error() do
    IO.puts("Halt on error with context:")

    stream_work()
    |> Enum.reduce_while([], fn
      {:error, _error, _context} = error, _result ->
        {:halt, error}

      result, results ->
        {:cont, [result | results]}
    end)
    |> case do
      {:error, _error, _context} = error -> error
      results -> Enum.reverse(results)
    end
    |> IO.inspect()
  end

  defp work(n) do
    if :rand.uniform(10) == 1 do
      raise "Oops!"
    else
      {:result, :rand.uniform(n * 100)}
    end
  end

  defp make_work_safe(dangerous_work, arg) do
    try do
      apply(dangerous_work, [arg])
    rescue
      error ->
        {:error, error, arg}
    end
  end

  defp stream_work do
    Stream.iterate(1, &(&1 + 1))
    |> Stream.map(fn i -> make_work_safe(&work/1, i) end)
  end
end
