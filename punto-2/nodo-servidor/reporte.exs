Code.require_file("ciudad.exs", __DIR__)
Code.require_file("movimiento.exs", __DIR__)

defmodule Reporte do
  @moduledoc """
  calculos y generacion de texto para el reporte de sismos por ciudad.
  - Autores: Simón Valencia Ochoa y Samuel Marín Varón
  - Fecha: Noviembre de 2026
  - Licencia: GNU GPL v3
  """

  @linea_doble "======"
  @linea_simple "---"

  @doc """
  genera el texto del reporte de todas las ciudades que sean validas con sus movimientos y estadísticas
  los parametros son:
    - lectura_ciudades: %{registros: ciudades, rechazados: cantidad}
    - lectura_movimientos: %{registros: movimientos, rechazados: cantidad}
  """
  def generar_reporte_general(lectura_ciudades, lectura_movimientos) do
    datos = asociar_movimientos(lectura_ciudades, lectura_movimientos)

    [
      generar_encabezado("- - - - Reporte de sismos por cada ciudad - - - -"),
      generar_secciones(datos.ciudades, datos.movimientos),
      generar_resumen_rechazados(datos)
    ]
    |> Enum.join("\n")
  end

  @doc """
  genera el reporte para una sola ciudad en base a la id o indica si no está registrada.
  """
  def generar_reporte_ciudad(lectura_ciudades, lectura_movimientos, id_ciudad) do
    datos = asociar_movimientos(lectura_ciudades, lectura_movimientos)

    case Enum.find(datos.ciudades, fn ciudad -> ciudad.id == id_ciudad end) do
      nil ->
        "la ciudad no se encuentra registrada"

      ciudad ->
        [
          generar_encabezado("REPORTE DE LA CIUDAD #{id_ciudad}"),
          generar_seccion_ciudad(ciudad, datos.movimientos),
          @linea_doble
        ]
        |> Enum.join("\n")
    end
  end

  @doc """
  filtra los movimientos de ciudades que sean validos y suma los que no pasaron a los rechazados.
  Retorna un mapa que tiene :ciudades, :movimientos, :rechazados_ciudades y :rechazados_movimientos
  """
  def asociar_movimientos(lectura_ciudades, lectura_movimientos) do
    ids_validos = Enum.map(lectura_ciudades.registros, fn ciudad -> ciudad.id end)

    {asociados, sin_ciudad} =
      Enum.split_with(lectura_movimientos.registros, fn movimiento ->
        movimiento.id_ciudad in ids_validos
      end)

    %{
      ciudades: lectura_ciudades.registros,
      movimientos: asociados,
      rechazados_ciudades: lectura_ciudades.rechazados,
      rechazados_movimientos: lectura_movimientos.rechazados + length(sin_ciudad)
    }
  end

  @doc """
  recorre recursivamente los movimientos de una ciudad y calcula, en un solo recorrido, su cantidad de movimientos, cual fue el movimiento de mayor magnitud y cual es la suma de profundidades.
  si varios tienen la misma magnitud máxima se conserva el primero del archivo.
  estaria retornando:
    {cantidad, movimiento_mayor, suma_profundidades}
    (movimiento_mayor es nil cuando la ciudad no tiene movimientos)
  """
  def calcular_estadisticas(movimientos) do
    calcular_estadisticas(movimientos, 0, nil, 0.0)
  end

  # Caso base que rompe la recursión: no quedarian movimientos por recorrer y retorna los acumulados.
  defp calcular_estadisticas([], cantidad, mayor, suma_profundidades) do
    {cantidad, mayor, suma_profundidades}
  end

  # caso recursivo: procesa la cabeza y posteriormente lo hace con la cola
  defp calcular_estadisticas([movimiento | resto], cantidad, mayor, suma_profundidades) do
    calcular_estadisticas(
      resto,
      cantidad + 1,
      elegir_mayor(movimiento, mayor),
      suma_profundidades + movimiento.profundidad
    )
  end

  # retorna el movimiento mayor magnitud entre el actual y el que se tiene como mayor hasta el momento
  # solo cambia si es mayor, si es menor o igual se converva el que ya se tiene como mayor
  defp elegir_mayor(movimiento, nil), do: movimiento

  defp elegir_mayor(
         %Movimiento{magnitud: magnitud} = movimiento,
         %Movimiento{magnitud: magnitud_mayor}
       )
       when magnitud > magnitud_mayor do
    movimiento
  end

  defp elegir_mayor(_movimiento, mayor), do: mayor

  @doc """
  calcula la profundidad promedio. retorna :no_aplica si la cantidad es cero.
  """
  def calcular_promedio(_suma_profundidades, 0), do: :no_aplica
  def calcular_promedio(suma_profundidades, cantidad), do: suma_profundidades / cantidad

  # aqui genera el encabezado del reporte con el titulo recibido.
  defp generar_encabezado(titulo) do
    [@linea_doble, titulo, "observatorio sismico de la universidad del Quindio", @linea_doble]
    |> Enum.join("\n")
  end

  # genera la sección de cada ciudad válida, separadas por una línea.
  defp generar_secciones([], _movimientos), do: "no existen ciudades validas para generar el reporte"

  defp generar_secciones(ciudades, movimientos) do
    ciudades
    |> Enum.map(fn ciudad -> generar_seccion_ciudad(ciudad, movimientos) end)
    |> Enum.join("\n" <> @linea_simple <> "\n")
  end

  # genera el texto de una ciudad con datos, detalle del movimientos y estadísticas.
  defp generar_seccion_ciudad(ciudad, movimientos) do
    movimientos_ciudad =
      Enum.filter(movimientos, fn movimiento -> movimiento.id_ciudad == ciudad.id end)

    {cantidad, mayor, suma_profundidades} = calcular_estadisticas(movimientos_ciudad)
    promedio = calcular_promedio(suma_profundidades, cantidad)

    [
      "ciudad: #{ciudad.nombre} (#{ciudad.id})",
      "habilidades: #{ciudad.habitantes}",
      "movimientos registrados:",
      generar_detalle(movimientos_ciudad),
      "total del movimiento: #{cantidad}",
      "movimiento de mayor magnitud: #{texto_mayor_magnitud(mayor)}",
      "profundidad promedio: #{texto_promedio(promedio)}"
    ]
    |> Enum.join("\n")
  end

  # genera un listado de movimientos de la ciudad o el aviso si es que no tiene.
  defp generar_detalle([]), do: "  sin movimientos registrados (de momento)"

  defp generar_detalle(movimientos) do
    movimientos
    |> Enum.map(&generar_texto_movimiento/1)
    |> Enum.join("\n")
  end

  # genera la linea de un movimiento con codigo, horas, magnitud y profundidad.
  defp generar_texto_movimiento(movimiento) do
    "  - #{movimiento.codigo} | Inicio: #{movimiento.hora_inicio} | " <>
      "final: #{movimiento.hora_final} | magnitud: #{movimiento.magnitud} | " <>
      "profundidad: #{movimiento.profundidad} km"
  end

  # texto del movimiento de mayor magnitud (código y magnitud) o un "no aplica".
  defp texto_mayor_magnitud(nil), do: "no aplica"
  defp texto_mayor_magnitud(movimiento), do: "#{movimiento.codigo} · #{movimiento.magnitud}"

  # texto de la profundidad promedio con dos cifras decimales o damos un "no aplica".
  defp texto_promedio(:no_aplica), do: "no aplica"
  defp texto_promedio(promedio), do: "#{:erlang.float_to_binary(promedio, decimals: 2)} km"

  # genera el resumen de registros rechazados que son separado por archivo.
  defp generar_resumen_rechazados(datos) do
    [
      @linea_doble,
      "registro rechazados por archivo",
      "  - ciudades.txt: #{datos.rechazados_ciudades}",
      "  - movimientos.txt: #{datos.rechazados_movimientos}",
      @linea_doble
    ]
    |> Enum.join("\n")
  end
end
