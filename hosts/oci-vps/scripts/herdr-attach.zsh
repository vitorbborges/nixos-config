if [[ -z "$HERDR_ENV" && $- == *i* ]]; then
  exec herdr
fi
