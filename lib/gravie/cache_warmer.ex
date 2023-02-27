defmodule Gravie.CacheWarmer do
  use Cachex.Warmer
  alias Gravie.CacheModule

  def interval, do: :timer.minutes(60)

  def execute(_args) do
    with {:ok, data} <- CacheModule.get_data_somewhere() do
      {:ok, data, [ttl: :timer.minutes(60)]}
    end
  end
end
