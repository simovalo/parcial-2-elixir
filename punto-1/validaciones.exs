defmodule Validaciones do
  @moduledoc """
  validacion y conversion de campos de texto leídos.
  las usamos en los structs Ciudad y Movimiento para decidir si una linea se acepta o se rechaza.
  - Autores: Simón Valencia Ochoa y Samuel Marín Varón
  - Fecha: Noviembre de 2026
  - Licencia: GNU GPL v3
  """

  @digitos ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

  @doc """
  retorna `true` si la lista de campos tiene al menos un elemento vacío.
  """
  def hay_campo_vacio?(campos) do
    Enum.any?(campos, fn campo -> campo == "" end)
  end

  @doc """
  convierte un texto en un numero entero
  Retorna {:ok, entero} o :error.
  """
  def convertir_entero(texto) do
    try do
      {:ok, String.to_integer(texto)}
    rescue
      ArgumentError -> :error
    end
  end

  @doc """
  convierte un texto en un numero decimal. Si es un entero, lo vuelve a float.
  Retorna {:ok, decimal} o :error.
  """
  def convertir_decimal(texto) do
    try do
      {:ok, String.to_float(texto)}
    rescue
      ArgumentError -> convertir_entero_a_decimal(texto)
    end
  end

  # aqui intenta leer el texto como entero y lo transforma en decimal
  defp convertir_entero_a_decimal(texto) do
    case convertir_entero(texto) do
      {:ok, numero} -> {:ok, numero * 1.0}
      :error -> :error
    end
  end

  @doc """
  verifica que el resultado de una conversión sea {:ok, número} y el numero sea mayor que cero
  """
  def mayor_que_cero?({:ok, numero}) when numero > 0, do: true
  def mayor_que_cero?(_resultado), do: false

  @doc """
  verifica que el resultado de una conversion sea {:ok, número} y el numero sea mayor o igual a cero
  """
  def mayor_o_igual_a_cero?({:ok, numero}) when numero >= 0, do: true
  def mayor_o_igual_a_cero?(_resultado), do: false

  @doc """
  Valida que el texto cumpla con el formato HH:MM:SS de 24 horas
  """
  def hora_valida?(texto) do
    case String.split(texto, ":") do
      [horas, minutos, segundos] ->
        parte_valida?(horas, 0..23) and parte_valida?(minutos, 0..59) and
          parte_valida?(segundos, 0..59)

      _ ->
        false
    end
  end

  # verifica que una parte de la hora tenga dos dígitos y esté dentro del rango permitido.
  defp parte_valida?(texto, rango) do
    String.length(texto) == 2 and solo_digitos?(texto) and String.to_integer(texto) in rango
  end

  # verifica que todos los caracteres del texto sean dígitos del 0 al 9.
  defp solo_digitos?(texto) do
    Enum.all?(String.graphemes(texto), fn caracter -> caracter in @digitos end)
  end
end
