Code.require_file("util.ex", __DIR__)
Code.require_file("coordinador.exs", __DIR__)
Code.require_file("reporte.exs", __DIR__)

defmodule NodoServidor do
  @moduledoc """
  Nodo servidor para atender solicitudes de reportes de sismos.
  Reutiliza los structs, las validaciones y los cálculos del punto 1.
  - Autores: Simón Valencia Ochoa y Samuel Marín Varón
  - Fecha: Noviembre de 2026
  - Licencia: GNU GPL v3
  """

  @nombre_servicio_local :servicio_sismos
  @rutas %{ciudades: "resources/ciudades.txt", movimientos: "resources/movimientos.txt"}

  @doc """
  inicia el servidor: registra el servicio y entra en el ciclo para esperar las solicitudes.
  """
  def main() do
    Util.mostrar_mensaje("nodo del servidor del observatorio Sismológico UQ")
    registrar_servicio(@nombre_servicio_local)
    Util.mostrar_mensaje("servicio #{@nombre_servicio_local} activo en el nodo #{node()}")
    atender_solicitudes()
  end

  # registra el proceso que esta actualmente con un nombre para que otros nodos le puedan enviar mensajes.
  defp registrar_servicio(nombre_servicio_local),
    do: Process.register(self(), nombre_servicio_local)

  # recibe una solicitud {destino_respuesta, solicitud}, lo cual envia la respuesta a ese destino y vuelve a esperar con un llamado recursivo. recibir :fin confirma con :fin.
  defp atender_solicitudes() do
    receive do
      {destino, :fin} ->
        Util.mostrar_mensaje("solicitud :fin de #{inspect(destino)}. entonces la confirmacion.")
        send(destino, :fin)

      {destino, solicitud} ->
        Util.mostrar_mensaje("solicitud #{inspect(solicitud)} de #{inspect(destino)}")
        send(destino, procesar_solicitud(solicitud))

      mensaje ->
        Util.mostrar_error("mensaje con formato no reconocido: #{inspect(mensaje)}")
    end

    atender_solicitudes()
  end

  # reporte de una ciudad que lee los archivos actuales y genera el reporte de la ciudad.
  defp procesar_solicitud({:reporte_ciudad, id_ciudad}) do
    consultar(fn lectura_ciudades, lectura_movimientos ->
      Reporte.generar_reporte_ciudad(lectura_ciudades, lectura_movimientos, id_ciudad)
    end)
  end

  # reporte general que lee los archivos actuales y genera el reporte de todas las ciudades que tiene el archivo.
  defp procesar_solicitud(:reporte_general) do
    consultar(&Reporte.generar_reporte_general/2)
  end

  # cualquier otra solicitud se responde con un aviso
  defp procesar_solicitud(solicitud) do
    "la solicitud #{inspect(solicitud)} no es reconocida "
  end

  # lee concurrentemente los dos archivos (punto 1) y aplica la funcioon que genera el reporte.
  # si algun archivo no podemos leerlo, responde con el mensaje que identifica el archivo.
  defp consultar(generar_reporte) do
    case Coordinador.leer_archivos(@rutas) do
      {:ok, lectura_ciudades, lectura_movimientos} ->
        generar_reporte.(lectura_ciudades, lectura_movimientos)

      {:error, errores} ->
        Enum.join(errores, "\n")
    end
  end
end

NodoServidor.main()
