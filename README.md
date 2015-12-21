# Riboflavin

Library for interacting with Backblaze B2


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add riboflavin, httpoison, and poison to your list of dependencies in `mix.exs`:

        def deps do
          [{:riboflavin, "~> 0.0.2"},
           {:poison, "~> 1.2"},
           {:httpoison, "~> 0.8.0"}]
        end

  2. Ensure riboflavin is started before your application. You can skip this step if you're only using the b2 API functions:

        def application do
          [applications: [:riboflavin]]
        end

  3. Run:

        mix deps.get


## Usage

There are two modules available to use. The `B2` module and the `API` module. The `API` module contains wrappers around the basic B2 API and requires you to manage to all the authentication on your own. The `B2` module is a collection of helper functions that take care of authorizing and keeping track of your authentication tokens. All `B2` functions match the `API` functions but without the b2_ in front.

Specify your `B2_ACCOUNT_ID` and `B2_APP_KEY` ENV variables or put them in the config.exs file like below:

    config :riboflavin,
      account_id: "myaccountid",
      application_key: "myappkey"

