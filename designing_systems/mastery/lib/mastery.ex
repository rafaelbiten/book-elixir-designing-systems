defmodule Mastery do
  alias Mastery.Boundary.{QuizSession, QuizManager, Proctor}
  alias Mastery.Boundary.Validator
  alias Mastery.Core.Quiz
  alias Mastery.Examples.Math

  @persistence_fn Application.get_env(:mastery, :persistence_fn)

  def schedule_quiz(quiz, templates, start_at, end_at, notify_pid \\ nil) do
    with :ok <- Validator.Quiz.errors(quiz),
         true <- Enum.all?(templates, &(:ok == Validator.Template.errors(&1))),
         :ok <- Proctor.schedule_quiz(quiz, templates, start_at, end_at, notify_pid),
         do: :ok,
         else: (error -> error)
  end

  def build_quiz(fields) do
    with :ok <- Validator.Quiz.errors(fields),
         :ok <- QuizManager.build_quiz(fields),
         do: :ok,
         else: (error -> error)
  end

  def add_template(title, fields) do
    with :ok <- Validator.Template.errors(fields),
         :ok <- QuizManager.add_template(title, fields),
         do: :ok,
         else: (error -> error)
  end

  def take_quiz(title, email) do
    with %Quiz{} = quiz <- QuizManager.lookup_quiz_by_title(title),
         {:ok, _child} <- QuizSession.take_quiz(quiz, email) do
      {title, email}
    else
      error -> error
    end
  end

  def select_question(session) do
    QuizSession.select_question(session)
  end

  def answer_question(session, answer, persistence_fn \\ @persistence_fn) do
    QuizSession.answer_question(session, answer, persistence_fn)
  end

  # EXAMPLE

  def run_example_worker() do
    now = DateTime.utc_now()
    five_seconds_from_now = DateTime.add(now, 5)
    one_minute_from_now = DateTime.add(now, 60)

    Mastery.schedule_quiz(
      Mastery.Examples.Math.quiz_fields(),
      [Math.template_fields()],
      five_seconds_from_now,
      one_minute_from_now
    )
  end

  def check_example_worker() do
    %{title: title} = Math.quiz_fields()
    Mastery.take_quiz(title, "my@email.com")
    QuizSession.active_sessions_for(title)
  end
end
