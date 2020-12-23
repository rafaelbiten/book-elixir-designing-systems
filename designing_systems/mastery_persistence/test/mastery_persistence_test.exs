defmodule MasteryPersistenceTest do
  use ExUnit.Case

  alias MasteryPersistence.{Response, Repo}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    response = %{
      quiz_title: :simple_addition,
      template_name: :single_digit_addition,
      to: "3 + 4",
      email: "my@email.com",
      answer: "7",
      correct: "true",
      timestamp: DateTime.utc_now()
    }

    {:ok, %{response: response}}
  end

  test "responses are recorded", %{response: response} do
    assert Repo.aggregate(Response, :count, :id) == 0
    assert :ok = MasteryPersistence.record_response(response)

    assert Repo.all(Response)
           |> Enum.map(fn r -> r.email end) == [response.email]

    assert Repo.aggregate(Response, :count, :id) == 1
  end

  test "cb fns can be run on record response", %{response: response} do
    assert {:ok, response.answer} ==
             MasteryPersistence.record_response(response, fn r -> {:ok, r.answer} end)
  end

  test "an error in the function rolls back the save", %{response: response} do
    assert Repo.aggregate(Response, :count, :id) == 0

    assert_raise RuntimeError, fn ->
      MasteryPersistence.record_response(response, fn _r -> raise "error" end)
    end

    assert Repo.aggregate(Response, :count, :id) == 0
  end

  test "simple reporting", %{response: response} do
    MasteryPersistence.record_response(response)
    MasteryPersistence.record_response(response)

    other_email = "other@email.com"

    response
    |> Map.put(:email, other_email)
    |> MasteryPersistence.record_response()

    expected_report = %{response.email => 2, other_email => 1}
    assert MasteryPersistence.report(response.quiz_title) == expected_report
  end
end
