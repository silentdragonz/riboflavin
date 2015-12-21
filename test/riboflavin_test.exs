defmodule RiboflavinTest do
  use ExUnit.Case
  doctest Riboflavin

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "authorize_account ok" do
    B2_ACCOUNT_ID = 1328382
    B2_APP_KEY = "sadflk3j8ecj8"
    response = Riboflavin.B2.b2_authorize_account(B2_ACCOUNT_ID, B2_APP_KEY)
    assert response.status == 200
    assert response.body == %{body: body}
  end

  test "authorize_account error" do
    B2_ACCOUNT_ID = 1328382
    B2_APP_KEY = "sadflk3j8ecj8"
    response = Riboflavin.B2.b2_authorize_account(B2_ACCOUNT_ID, B2_APP_KEY)
    assert response.status == 401
    assert response.body == %{message: body}
  end
end
