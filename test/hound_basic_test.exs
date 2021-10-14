defmodule HoundBasicTest do
  use ExUnit.Case
  doctest HoundBasic

  test "greets the world" do
    assert HoundBasic.hello() == :world
  end
end
