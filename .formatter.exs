[
  inputs: [
    "mix.exs",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  line_length: 120,
  locals_without_parens: [
    resources: :*,
    post: :*,
    delete: :*,
    get: :*,
    field: :*
  ]
]
