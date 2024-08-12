defmodule Renewex.Storable do
  @moduledoc """

  """

  alias Renewex.Storable

  @doc """

  """
  defstruct [:class_name, :fields]

  @doc """

  """
  def new(class_name) do
    %Storable{
      class_name: class_name,
      fields: %{}
    }
  end
end
