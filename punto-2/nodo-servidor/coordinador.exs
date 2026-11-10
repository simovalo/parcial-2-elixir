Code.require_file("ciudad.exs", __DIR__)
Code.require_file("movimiento.exs", __DIR__)
Code.require_file("archivos.exs", __DIR__)

defmodule Coordinador do
  @moduledoc """
  coordinacion que usa la concurrente para la lectura de los archivos de ciudades y movimientos
  - Autores: Simón Valencia Ochoa y Samuel Marín Varón
  - Fecha: Noviembre de 2026
  - Licencia: GNU GPL v3
  """

  @tiempo_espera 5_000

  @doc """
  lee de forma concurrente los archivos indicados en el mapa de rutas (ciudades y movimientos).
  Retorna {:ok, lectura_ciudades, lectura_movimientos} si ambos fueron leidos correctamente, o {:error, mensajes} q detalla los fallos que tiene
  """
  def leer_archivos(rutas) do
    coordinador = self()
    referencia = make_ref()

    iniciar_trabajador(coordinador, referencia, :ciudades, rutas.ciudades, &Ciudad.convertir_linea/1)

    iniciar_trabajador(
      coordinador,
      referencia,
      :movimientos,
      rutas.movimientos,
      &Movimiento.convertir_linea/1
    )

    recibir_resultados(2, referencia, %{})
    |> evaluar_resultados(rutas)
  end

  # se crea un proceso trabajador que se encarga de leeer un archivo y enviar el resultado al proceso coordinador.
  # que identifica el archivo procesado y el resultado de la lectura o en su defecto el error
  defp iniciar_trabajador(coordinador, referencia, archivo, ruta, convertidor) do
    spawn(fn ->
      resultado = Archivos.leer_registros(ruta, convertidor)
      send(coordinador, {:archivo_procesado, referencia, archivo, resultado})
    end)
  end

  # caso base que rompe la recursividad: ya llegaron las respuestas de los dos trabajadores, retorna los resultados-
  defp recibir_resultados(0, _referencia, resultados), do: resultados

  # Caso recursivo: recibe la respuesta de cada trabajador y la guarda en un mapa
  # La referencia (^referencia) hace que no se confundan estos mensajes con los del buzón
  defp recibir_resultados(pendientes, referencia, resultados) do
    receive do
      {:archivo_procesado, ^referencia, archivo, resultado} ->
        recibir_resultados(pendientes - 1, referencia, Map.put(resultados, archivo, resultado))
    after
      @tiempo_espera -> resultados
    end
  end

  # si los archivos se leyeron bien, retorna los datos para generar el reporte al final
  defp evaluar_resultados(%{ciudades: {:ok, ciudades}, movimientos: {:ok, movimientos}}, _rutas) do
    {:ok, ciudades, movimientos}
  end

  # si falla alguno o no tiene una respuesta, crea un mensaje que identifica cda archivo con error
  defp evaluar_resultados(resultados, rutas) do
    errores =
      [:ciudades, :movimientos]
      |> Enum.map(fn archivo ->
        {archivo, Map.get(resultados, archivo, {:error, :sin_respuesta})}
      end)
      |> Enum.filter(fn {_archivo, resultado} -> elem(resultado, 0) == :error end)
      |> Enum.map(fn {archivo, {:error, razon}} ->
        generar_mensaje_error(Map.get(rutas, archivo), razon)
      end)

    {:error, errores}
  end

  # genera el texto con error y dice la ruta del archivo que fallo
  defp generar_mensaje_error(ruta, :sin_respuesta) do
    "Error con el archivo #{ruta}: el proceso trabajador no respondió a tiempo"
  end

  defp generar_mensaje_error(ruta, razon) do
    "No se pudo leer el archivo #{ruta}: #{Archivos.describir_error(razon)}"
  end
end
