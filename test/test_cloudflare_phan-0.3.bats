setup() {
  docker history "cloudflare/phan:0.3" >/dev/null 2>&1
}

@test "pass arguments to phan" {
  run docker run -v $PWD/test/fixtures/pass:/mnt/src "cloudflare/phan:0.3" -h
  [ $status -eq 0 ]
  [ "${lines[0]}" = "Usage: /opt/phan/phan [options] [files...]" ]
}

@test "outputs zero lines if source has no issues" {
  run docker run -v $PWD/test/fixtures/pass:/mnt/src "cloudflare/phan:0.3" \
      -l .
  [ $status -eq 0 ]
  [ ${#lines[@]} -eq 0 ]
}

@test "outputs lines if source has issues" {
  run docker run -v $PWD/test/fixtures/fail:/mnt/src "cloudflare/phan:0.3" \
      -l .

  # even if there's failures, phan reports 0
  [ $status -eq 0 ]

  [ ${#lines[@]} -eq 2 ]
  [ "${lines[0]}" = "./undefined_class.php:3 PhanUndeclaredClassMethod Call to method __construct from undeclared class \stub" ]
  [ "${lines[1]}" = "./undefined_class.php:4 PhanUndeclaredClassConstant Reference to constant TYPE_STRING from undeclared class \stub" ]
}

@test "checkstyle output format is available" {
  run docker run -v $PWD/test/fixtures/pass:/mnt/src "cloudflare/phan:0.3" \
      --output-mode checkstyle -l .
  [ $status -eq 0 ]
  [ ${#lines[@]} -eq 2 ]
}
