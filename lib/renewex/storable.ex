defmodule Renewex.Storable do
  alias Renewex.Storable
  defstruct [:class_name, :fields]

  def new(class_name) do
    %Storable{
      class_name: class_name,
      fields: %{}
    }
  end
end
