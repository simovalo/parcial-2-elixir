defmodule Archivos do
  @moduledoc """
  lectura y escritura de archivos de texto del observatorio
  se encarga de separar el manejo de archivos de lo que es el calculo de reporte y de la coordinacion de procesos
  - Autores: Simón Valencia Ochoa y Samuel Marín Varón
  - Fecha: Noviembre de 2026
  - Licencia: GNU GPL v3
  """

  @doc """
  lee un archivo y convierte cada linea usando convertidor (valga la redundancia) que es una funcion, ignora vacios
  retorna {:ok, %{registros: lista, rechazados: cantidad}} o {:error, razon}
  """
  def leer_registros(ruta, convertidor) do
    case File.read(ruta) do
      {:ok, contenido} -> {:ok, procesar_contenido(contenido, convertidor)}
      {:error, razon} -> {:error, razon}
    end
  end

  # aqui divide el contenido en lienas, quita los vacios y separa los registros validos de los que se rechazan. y como algunos editores de windows agregan BOM lo quita
  defp procesar_contenido(contenido, convertidor) do
    resultados =
      contenido
      |> String.replace("\uFEFF", "")
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.filter(fn linea -> linea != "" end)
      |> Enum.map(convertidor)

    {validos, rechazados} =
      Enum.split_with(resultados, fn resultado -> elem(resultado, 0) == :ok end)

    %{
      registros: Enum.map(validos, fn {:ok, registro} -> registro end),
      rechazados: length(rechazados)
    }
  end

  @doc """
  Guarda un texto en un archivo y reemplaza su contenido anterior.
  Retorna :ok o {:error, razon}.
  """
  def guardar_texto(ruta, texto) do
    File.write(ruta, texto)
  end

  @doc """
  traduce un código de error de archivo a un mensaje leible.
  """
  def describir_error(:enoent), do: "lo que es la carpeta o el archivo no existe"
  def describir_error(:eacces), do: "no tiene permiso de acceder a este archivo o carpeta"
  def describir_error(:eisdir), do: "la ruta dada corresponde a una carpeta, no a un archivo"
  def describir_error(razon), do: "#{inspect(razon)}"
end
