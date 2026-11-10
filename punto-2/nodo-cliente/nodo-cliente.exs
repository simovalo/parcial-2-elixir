Code.require_file("util.ex", __DIR__)

defmodule NodoCliente do
  @moduledoc """
  nodo cliente. estaria conecta al nodo servidor, envía las solicitudes de reportes
  al proceso :servicio_sismos y muestra cada respuesta hasta recibir :fin.
  - Autores: Simón Valencia Ochoa y Samuel Marín Varón
  - Fecha: Noviembre de 2026
  - Licencia: GNU GPL v3
  """

  @nombre_servicio_local :servicio_respuesta
  # Se usa la IP 127.0.0.1 porque con --name Erlang me pide un host con punto (y no se puede uar un localhost).
  @nodo_remoto :"nodoservidor@127.0.0.1"
  @servicio_remoto {:servicio_sismos, @nodo_remoto}
  @tiempo_espera 15_000

  # Solicitudes en el orden pedido: ciudad con movimientos (C01), ciudad sin movimientos (C03),
  #  ciudad  que no existe (C99) y reporte general. el :fin se envía después de estas.
  @solicitudes [
    {:reporte_ciudad, "C01"},
    {:reporte_ciudad, "C03"},
    {:reporte_ciudad, "C99"},
    :reporte_general
  ]

  @doc """
  inicia el cliente: registra su servicio local, se conecta al servidor y envia las solicitudes
  """
  def main() do
    Util.mostrar_mensaje("nodo del cliente que consulta de reportes sismicos")
    registrar_servicio(@nombre_servicio_local)

    @nodo_remoto
    |> establecer_conexion()
    |> iniciar_consultas()
  end

  # registra el proceso actual para que el server le responda por nombre
  defp registrar_servicio(nombre_servicio_local),
    do: Process.register(self(), nombre_servicio_local)

  # intenta conectar a el server, retorna true, false o :ignored
  defp establecer_conexion(nodo_remoto), do: Node.connect(nodo_remoto)

  # conexion exitosa: envia todas las solicitudes y espera a recibir respuesta
  defp iniciar_consultas(true) do
    enviar_solicitudes()
    recibir_respuestas(@solicitudes)
  end

  # conexion fallida, da informe de error y el programa termina.
  defp iniciar_consultas(false),
    do: Util.mostrar_error("no pudo conectar con el nodo servidor #{@nodo_remoto}")

  # el nodo cliente se inicia sin ningun nombre, por lo que no puede conectarse
  defp iniciar_consultas(:ignored),
    do: Util.mostrar_error("el nodo cliente no esta en modo distribuido; por lo que tiene que ejecutarlo con --name")

  # envia las solicitudes en orden y al final envia:fin
  defp enviar_solicitudes() do
    Enum.each(@solicitudes ++ [:fin], &enviar_solicitud/1)
  end

  # cada mensaje tiene la forma {destino_respuesta, solicitud}.
  defp enviar_solicitud(solicitud) do
    send(@servicio_remoto, {destino_respuesta(), solicitud})
  end

  # Proceso registrado y nodo cliente a donde el servidor deberia enviar la respuesta.
  # se usa node() para tomar el nombre real con el que se inicio este nodo
  defp destino_respuesta(), do: {@nombre_servicio_local, node()}

  # Recibe las respuestas de forma recursiva hasta que llega :fin.
  defp recibir_respuestas(solicitudes_pendientes) do
    receive do
      :fin ->
        Util.mostrar_mensaje("\nconfirmacion :fin recibida. no mas consultas.")

      respuesta ->
        solicitudes_pendientes
        |> mostrar_respuesta(respuesta)
        |> recibir_respuestas()
    after
      @tiempo_espera ->
        Util.mostrar_error("el servidor no respondio en #{@tiempo_espera} ms. el cliente termina al instante.")
    end
  end

  # Muestra la respuesta junto a la solicitud que la originó y retorna las que faltan.
  defp mostrar_respuesta([solicitud | resto], respuesta) do
    Util.mostrar_mensaje("\n> respuesta a #{inspect(solicitud)}")
    Util.mostrar_mensaje(respuesta)
    resto
  end

  defp mostrar_respuesta([], respuesta) do
    Util.mostrar_mensaje(respuesta)
    []
  end
end

NodoCliente.main()
