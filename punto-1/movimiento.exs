Code.require_file("validaciones.exs", __DIR__)

defmodule Movimiento do
  @moduledoc """
  Struct que representa un movimiento sismico (resources/movimientos.txt)
  Formato: codigo@idCiudad@horaInicio@horaFinal@magnitud@profundidad
  - Autores: Simón Valencia Ochoa y Samuel Marín Varón
  - Fecha: Noviembre de 2026
  - Licencia: GNU GPL v3
  """

  defstruct codigo: "",
            id_ciudad: "",
            hora_inicio: "",
            hora_final: "",
            magnitud: 0.0,
            profundidad: 0.0

  @doc """
  crea un struct `%Movimiento{}` con datos que ya fueron validados.
  """
  def crear(codigo, id_ciudad, hora_inicio, hora_final, magnitud, profundidad) do
    %Movimiento{
      codigo: codigo,
      id_ciudad: id_ciudad,
      hora_inicio: hora_inicio,
      hora_final: hora_final,
      magnitud: magnitud,
      profundidad: profundidad
    }
  end

  @doc """
  convierte una línea de texto en un struct `%Movimiento{}`.
  retorna {:ok, movimiento} o {:error, motivo} si algo es invalido
  """
  def convertir_linea(linea) do
    campos =
      linea
      |> String.split("@")
      |> Enum.map(&String.trim/1)

    case campos do
      [_codigo, _id_ciudad, _hora_inicio, _hora_final, _magnitud, _profundidad] ->
        validar_campos(campos)

      _ ->
        {:error, "no tiene el formato código@idCiudad@horaInicio@horaFinal@magnitud@profundidad"}
    end
  end

  # Revisa campos vacíos, las dos horas, la magnitud decimal y la profundidad mayor o igual a cero.
  defp validar_campos(
         [codigo, id_ciudad, hora_inicio, hora_final, texto_magnitud, texto_profundidad] = campos
       ) do
    magnitud = Validaciones.convertir_decimal(texto_magnitud)
    profundidad = Validaciones.convertir_decimal(texto_profundidad)

    cond do
      Validaciones.hay_campo_vacio?(campos) ->
        {:error, "campo esta vacio, y es obligatorio"}

      not Validaciones.hora_valida?(hora_inicio) ->
        {:error, "hora de inicio no valida"}

      not Validaciones.hora_valida?(hora_final) ->
        {:error, "hora final no valida"}

      magnitud == :error ->
        {:error, "magnitud no valida"}

      not Validaciones.mayor_o_igual_a_cero?(profundidad) ->
        {:error, "profundidad no valida"}

      true ->
        {:ok,
         crear(codigo, id_ciudad, hora_inicio, hora_final, elem(magnitud, 1), elem(profundidad, 1))}
    end
  end
end
