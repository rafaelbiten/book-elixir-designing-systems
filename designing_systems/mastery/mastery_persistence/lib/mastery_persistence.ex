defmodule MasteryPersistence do
  import Ecto.Query, only: [from: 2]
  alias MasteryPersistence.{Response, Repo}

  def record_response(response, in_transaction \\ fn _response -> :ok end) do
    {:ok, result} =
      Repo.transaction(fn ->
        %{
          quiz_title: to_string(response.quiz_title),
          template_name: to_string(response.template_name),
          to: response.to,
          email: response.email,
          answer: response.answer,
          correct: response.correct,
          inserted_at: response.timestamp,
          updated_at: response.timestamp
        }
        |> Response.record_changeset()
        |> Repo.insert!()

        in_transaction.(response)
      end)

    result
  end

  def report(quiz_title) do
    quiz_title = to_string(quiz_title)

    from(
      response in Response,
      select: {response.email, count(response.id)},
      where: response.quiz_title == ^quiz_title,
      group_by: [response.quiz_title, response.email]
    )
    |> Repo.all()
    |> Enum.into(Map.new())
  end
end
