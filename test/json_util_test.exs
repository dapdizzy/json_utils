defmodule JsonUtilTest do
  use ExUnit.Case
  doctest JsonUtil

  test "greets the world" do
    assert JsonUtil.hello() == :world
  end
end
