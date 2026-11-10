Code.require_file("util.ex", __DIR__)
Code.require_file("archivos.exs", __DIR__)
Code.require_file("coordinador.exs", __DIR__)
Code.require_file("reporte.exs", __DIR__)

defmodule Observatorio do
  @moduledoc """
  Programa principal del punto 1 (reporte local).
  este genera el reporte de sismos por cada ciudad, lo muestra en consola y lo guarda en resources/reporte_sismos.txt. cada que genera, vuelve a leer los dos archivos.
  - Autores: Simón Valencia Ochoa y Samuel Marín Varón
  - Fecha: Noviembre de 2026
  - Licencia: GNU GPL v3
  """

  @rutas %{ciudades: "resources/ciudades.txt", movimientos: "resources/movimientos.txt"}
  @ruta_reporte "resources/reporte_sismos.txt"

  @doc """
  funcion principal. genera el reporte y permite regenerarlo de forma interactiva sin la necesidad de reiniciar el programa.
  """
  def main do
    generar_reporte()

    "\n desea generar el reporte nuevamente? (s/n): "
    |> Util.ingresar(:boolean)
    |> continuar()
  end

  # Si la respuesta es sí, vuelve a llamar a main (llamado recursivo); si no, termina.
  defp continuar(true), do: main()
  defp continuar(false), do: Util.mostrar_mensaje("Programa finalizado.")

  @doc """
  Lee los archivos de forma concurrente y, si ambos se leyeron bien, muestra el reporte
  y lo guarda. Si alguno falla, informa cuál fue y conserva el reporte anterior.
  """
  def generar_reporte do
    case Coordinador.leer_archivos(@rutas) do
      {:ok, lectura_ciudades, lectura_movimientos} ->
        reporte = Reporte.generar_reporte_general(lectura_ciudades, lectura_movimientos)
        Util.mostrar_mensaje(reporte)
        guardar_reporte(reporte)

      {:error, errores} ->
        Enum.each(errores, &Util.mostrar_error/1)

        Util.mostrar_error(
          "no fue posible generar el reporte. se conserva el contenido de #{@ruta_reporte}"
        )
    end
  end

  # guarda el reporte en el archivo y tambien avisa en consola si la escritura falla
  defp guardar_reporte(reporte) do
    case Archivos.guardar_texto(@ruta_reporte, reporte) do
      :ok ->
        Util.mostrar_mensaje("\nreporte guardado en #{@ruta_reporte}")

      {:error, razon} ->
        Util.mostrar_error(
          "no fue posible hacer el guardado del reporte en #{@ruta_reporte}: #{Archivos.describir_error(razon)}"
        )
    end
  end
end

Observatorio.main()
