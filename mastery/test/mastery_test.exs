defmodule MasteryTest do
  use ExUnit.Case, async: false
  use QuizBuilders

  alias MasteryPersistence.Repo
  alias MasteryPersistence.Response

  alias Mastery.Examples.Math
  alias Mastery.Boundary.QuizSession

  test "Take a quiz, manage lifecycle and persist responses" do
    session = take_quiz("name@mail.com")

    select_question(session)
    assert give_wrong_answer(session) == {"1 + 2", false}
    assert give_right_answer(session) == {"1 + 2", true}
    assert response_count() > 0

    assert give_right_answer(session) == :finished
    assert QuizSession.active_sessions_for(Math.quiz_fields().title) == []
  end

  # setup

  setup do
    enable_persistence()

    always_add_1_to_2 = [template_fields(generators: addition_generators([1], [2]))]

    assert "" !=
             ExUnit.CaptureLog.capture_log(fn ->
               :ok = start_quiz(always_add_1_to_2)
             end)

    :ok
  end

  # private

  defp start_quiz(fields) do
    now = DateTime.utc_now()
    ending = DateTime.add(now, 60)

    Mastery.schedule_quiz(Math.quiz_fields(), fields, now, ending)
  end

  defp take_quiz(email) do
    Mastery.take_quiz(Math.quiz().title, email)
  end

  defp select_question(session) do
    assert Mastery.select_question(session) == "1 + 2"
  end

  defp give_wrong_answer(session) do
    Mastery.answer_question(session, "wrong", &MasteryPersistence.record_response/2)
  end

  defp give_right_answer(session) do
    Mastery.answer_question(session, "3", &MasteryPersistence.record_response/2)
  end

  defp enable_persistence() do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(MasteryPersistence.Repo, {:shared, self()})
  end

  defp response_count() do
    Repo.aggregate(Response, :count, :id)
  end
end
