defmodule Util do
  @moduledoc """
  Módulo con funciones de entrada y salida que se reutilizan en el parcial.
  Basado en el módulo Util trabajado en clase.
  - Autores: Simón Valencia Ochoa y Samuel Marín Varón
  - Fecha: Noviembre de 2026
  - Licencia: GNU GPL v3
  """

  @doc """
  Muestra un mensaje en la consola.
  ## Parámetros
    - mensaje: texto que se le presenta al usuario
  ## Ejemplo
      iex> Util.mostrar_mensaje("Hola Mundo")
  """
  def mostrar_mensaje(mensaje) do
    mensaje
    |> IO.puts()
  end

  @doc """
  Muestra un mensaje de error en la salida estándar de error.
  ## Parámetros
    - mensaje: texto del error que se le presenta al usuario
  ## Ejemplo
      iex> Util.mostrar_error("No se pudo leer el archivo")
  """
  def mostrar_error(mensaje) do
    IO.puts(:standard_error, mensaje)
  end

  @doc """
  Lee un dato desde el teclado según el tipo indicado.
  - :texto retorna el texto sin espacios al inicio ni al final.
  - :boolean retorna true si el usuario responde "s", "si" o "sí".
  ## Ejemplo
      iex> Util.ingresar("¿Desea continuar? (s/n): ", :boolean)
  """
  def ingresar(mensaje, :texto) do
    mensaje
    |> IO.gets()
    |> String.trim()
  end

  def ingresar(mensaje, :boolean) do
    valor =
      mensaje
      |> ingresar(:texto)
      |> String.downcase()

    Enum.member?(["s", "si", "sí"], valor)
  end
end
