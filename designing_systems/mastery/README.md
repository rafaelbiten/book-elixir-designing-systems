# Mastery

This project was built by following the book [Designing Elixir Systems With OTP](https://pragprog.com/titles/jgotp/designing-elixir-systems-with-otp/) by James Edward Gray and Bruce A. Tate.

## Running an example on iex

```elixir
$ iex -S mix

alias Mastery.Examples.Math

email1 = "email1@test.com"
email2 = "email2@test.com"
title = Math.quiz.title

Mastery.build_quiz Math.quiz_fields
Mastery.add_template title, Math.template_fields

user1 = Mastery.take_quiz title, email1
user2 = Mastery.take_quiz title, email2

Mastery.select_question user1
Mastery.select_question user2
Mastery.answer_question user1, "6"
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mastery` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mastery, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/mastery](https://hexdocs.pm/mastery).

