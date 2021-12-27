import unittest

test "dasdasd":
    echo "ded obies"

suite "description for this stuff":
  echo "suite setup: run once before the tests"
  
  setup:
    echo "run before each test"
  
  teardown:
    echo "run after each test"
  
  test "essential truths":
    # give up and stop if this fails
    require(true)
  
  test "out of bounds error is thrown on bad access":
    let v = @[1, 2, 3]  # you can do initialization here
    expect(IndexDefect):
      discard v[4]
  
  echo "suite teardown: run once after the tests"
