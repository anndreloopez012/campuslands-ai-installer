#!/usr/bin/env python3
"""Copia un archivo desde un paquete .asar de Electron, sin depender de Node."""

import json
import struct
import sys


def extraer(ruta_asar, interno, destino):
    with open(ruta_asar, "rb") as asar:
        asar.seek(12)
        largo = struct.unpack("<I", asar.read(4))[0]
        indice = json.loads(asar.read(largo))
        base = (16 + largo + 3) & ~3
        nodo = indice
        for parte in interno.split("/"):
            nodo = nodo["files"][parte]
        asar.seek(base + int(nodo["offset"]))
        with open(destino, "wb") as salida:
            salida.write(asar.read(nodo["size"]))


if __name__ == "__main__":
    extraer(sys.argv[1], sys.argv[2], sys.argv[3])
