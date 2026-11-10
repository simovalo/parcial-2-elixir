Code.require_file("validaciones.exs", __DIR__)

defmodule Ciudad do
  @moduledoc """
  Struct que representa una ciudad y funciones para crearla y convertir líneas de archivo en ciudades.
  formato: idCiudad@nombre@numeroHabitantes
  - Autores: Simón Valencia Ochoa y Samuel Marín Varón
  - Fecha: Noviembre de 2026
  - Licencia: GNU GPL v3
  """

  defstruct id: "", nombre: "", habitantes: 0

  @doc """
  crea una ciudad con los datos ya validados.
  por ejemplo
      iex> Ciudad.crear("C01", "Armenia", 304314)
      %Ciudad{id: "C01", nombre: "Armenia", habitantes: 304314}
  """
  def crear(id, nombre, habitantes) do
    %Ciudad{id: id, nombre: nombre, habitantes: habitantes}
  end

  @doc """
  convierte una línea de texto en un struct `%Ciudad{}`.
  Retorna {:ok, ciudad} o {:error, motivo} si el formato o los datos son inválidos.
  poniendo de ejemplo
      iex> Ciudad.convertir_linea("C01@Armenia@304314")
      {:ok, %Ciudad{id: "C01", nombre: "Armenia", habitantes: 304314}}
  """
  def convertir_linea(linea) do
    campos =
      linea
      |> String.split("@")
      |> Enum.map(&String.trim/1)

    case campos do
      [_id, _nombre, _habitantes] -> validar_campos(campos)
      _ -> {:error, "no tiene el formato que podemos leer idCiudad@nombre@numeroHabitantes"}
    end
  end

  # revisa que no tenga campos vacios y que los habitantes sean enteros y mas que cero
  defp validar_campos([id, nombre, texto_habitantes] = campos) do
    habitantes = Validaciones.convertir_entero(texto_habitantes)

    cond do
      Validaciones.hay_campo_vacio?(campos) ->
        {:error, "campo hobligatorio vacio"}

      not Validaciones.mayor_que_cero?(habitantes) ->
        {:error, "numero de habitantes no valido"}

      true ->
        {:ok, crear(id, nombre, elem(habitantes, 1))}
    end
  end
end
