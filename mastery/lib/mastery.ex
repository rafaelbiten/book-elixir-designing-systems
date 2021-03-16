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

  def run_example_worker(start_in \\ 5, end_in \\ 60, notify_pid \\ nil) do
    now = DateTime.utc_now()
    start_in_seconds_from_now = DateTime.add(now, start_in)
    end_in_seconds_from_now = DateTime.add(now, end_in)

    Mastery.schedule_quiz(
      Mastery.Examples.Math.quiz_fields(),
      [Math.template_fields()],
      start_in_seconds_from_now,
      end_in_seconds_from_now,
      notify_pid
    )
  end

  def check_example_worker() do
    %{title: title} = Math.quiz_fields()
    Mastery.take_quiz(title, "my@email.com")
    QuizSession.active_sessions_for(title)
  end

  def check_pid_notification() do
    pid = spawn(Receiver, :run, [])
    run_example_worker(1, 2, pid)
  end
end

defmodule Receiver do
  def run do
    receive do
      message -> IO.inspect(message)
    end

    run()
  end
end
