defmodule TaflEngine.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: TaflEngine.Worker.start_link(arg)
      # {TaflEngine.Worker, arg}
      {Registry, keys: :unique, name: Registry.Game},
      TaflEngine.GameSupervisor
    ]

    :ets.new(:game_state, [:public, :named_table])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TaflEngine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
