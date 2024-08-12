defmodule Renewex.Storable do
  @moduledoc """
  In the original [Renew](http://renew.de) Java implementation a  `*.rnw` is deserialized 
  into Java Objects of a variaty of classes.

  Each of these classes implement the interface `Storable` that is responsible for reading/writing the token stream.

  This module defines a struct that captures the result of such a deserialization and reproduces that concept of a Java
  class consisting of various fields.

  The struct consists of the `class_name` (the fully qualified Java class of the object has has been parsed) and 
  the `fields` (a Map of key/value pairs representing the fields and values of the Java class)
  """

  alias Renewex.Storable

  @doc """
  The struct consists of the `class_name` (the fully qualified Java class of the object has has been parsed) and 
  the `fields` (a Map of key/value pairs representing the fields and values of the Java class)
  """
  defstruct [:class_name, :fields]

  @doc """
  Returns a new Storable struct representing an object of the given class_name.
  """
  def new(class_name) do
    %Storable{
      class_name: class_name,
      fields: %{}
    }
  end
end
