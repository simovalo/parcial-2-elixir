# Parcial 2 de programacion 3 (Elixir)

autores: Simón Valencia Ochoa y Samuel Marín Varón

# el punto 1 reporte local

arpeta desde la que se ejecuta: `punto-1`

```bash
elixir observatorio.exs
```

- archivo de entrada: `punto-1/resources/ciudades.txt` y `punto-1/resources/movimientos.txt`
- Reporte generado: `punto-1/resources/reporte_sismos.txt`

# el punto 2  consulta entre nodos

se usan dos terminales. primero se inicia el servidor y luego el cliente. los dos usan la misma cookie (`sismos_uq_2026`) con la opción `--cookie`.

|   Nodo   |     Nombre del nodo      |
|   ---    |            ---           |
| Servidor | `nodoservidor@127.0.0.1` |
| Cliente  | `nodocliente@127.0.0.1`  |

terminl 1, el Servidor (carpeta `punto-2/nodo-servidor`):

```bash
elixir --name nodoservidor@127.0.0.1 --cookie sismos_uq_2026 nodo-servidor.exs
```

terminal 2, el Cliente (carpeta `punto-2/nodo-cliente`):

```bash
elixir --name nodocliente@127.0.0.1 --cookie sismos_uq_2026 nodo-cliente.exs
```

## Verificación del punto 2

Identificadores que usa el cliente:

|          Caso          |   Identificador  |
|           ---          |        ---       |
| ciudad con movimientos | `C01` (Armenia)  |
| Ciudad sin movimientos | `C03` (Circasia) |
| Ciudad inexistente     |      `C99`       |

como queremos comprobar que sigue recibiendo el server, sin cerrar la terminal 1, se ejecuta otra vez en la terminal 2 el mismo comando del cliente:

```bash
elixir --name nodocliente@127.0.0.1 --cookie sismos_uq_2026 nodo-cliente.exs
```
