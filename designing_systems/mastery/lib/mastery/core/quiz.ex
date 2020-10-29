defmodule Mastery.Core.Quiz do
  defstruct title: nil,
            mastery: 3,
            record: %{},
            current_question: nil,
            last_response: nil,
            templates: %{},
            used: [],
            mastered: []
end
