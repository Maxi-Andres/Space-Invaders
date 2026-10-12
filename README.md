# Space Invaders en Assembly x8086

Un clon de **Space Invaders** escrito desde cero en **Assembly 8086** para DOS, compilado con Turbo Assembler (TASM). Todo corre en modo texto (80x25): los enemigos, la nave y el jefe final están dibujados con caracteres ASCII de bloque (`█ ▄ ▀`). Los sonidos salen del parlante interno de la PC.

```
     ▄█▄█▄          ▄█▄█▄          ▄█▄█▄
     █▄█▄█          █▄█▄█          █▄█▄█
      ▀ ▀            ▀ ▀            ▀ ▀

   ▄█▄█▄          ▄█▄█▄          ▄█▄█▄
 █▄█▄█▄█▄█      █▄█▄█▄█▄█      █▄█▄█▄█▄█
 ▄█ ▀ ▀ █▄      ▄█ ▀ ▀ █▄      ▄█ ▀ ▀ █▄

                     ¡

                    ▄█▄
```

---

## Cómo jugarlo

### Windows

No hay que instalar nada. El repo ya trae DOSBox 0.74 y TASM en `tools/`.

1. Clonar el repo, o bajarlo como ZIP desde GitHub y descomprimirlo.
2. Hacer doble click en **`install.bat`**.
3. Se abre DOSBox, que compila todo y arranca el juego. Entre cada paso de la compilación hay una pausa: apretar cualquier tecla para seguir.

### Linux / macOS

Instalar DOSBox con el gestor de paquetes (`apt install dosbox`, `brew install dosbox`, etc.) y, desde la carpeta del repo, ejecutar:

```
dosbox -conf dosbox.conf
```

---

## Controles

|   Tecla   | Acción                                                         |
| :-------: | -------------------------------------------------------------- |
|    `A`    | Mover a la izquierda                                           |
|    `D`    | Mover a la derecha                                             |
|    `W`    | Disparar                                                       |
|   `Esc`   | Salir                                                          |
| `Espacio` | Seguir jugando / reintentar (en las pantallas de fin de nivel) |

---

## Cómo se juega

- **18 enemigos en 3 filas** avanzan de lado a lado y bajan un renglón cada vez que llegan a un borde. Si alguno te toca o llega abajo de todo, perdés.
- **Puntaje según la fila:**

  | Enemigo                | Puntos |
  | ---------------------- | ------ |
  | Fila de arriba (verde) | 30     |
  | Fila del medio (cyan)  | 20     |
  | Fila de abajo (roja)   | 10     |
  | Nave secreta (magenta) | ?      |

- **Nave secreta:** cada tanto cruza la parte de arriba de la pantalla y se va. No hace falta matarla para pasar de nivel, pero da puntos extra.
- **4 niveles**, cada uno con otra velocidad. Se guardan el score y el highscore.
- **Jefe final:** después del cuarto nivel aparece un jefe grande (26x7 caracteres) que dispara al azar. Hay que pegarle 28 veces. En esta parte tenés 3 vidas.

---

## Cómo está hecho

El juego usa dos **interrupciones propias** que se instalan antes de arrancar. Son programas residentes (TSR) en formato `.COM`:

| Archivo        | Interrupción | Qué hace                                                                                                                                                                 |
| -------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `intSound.asm` | `int 80h`    | Hace sonar el parlante interno programando el timer (PIT, puerto `42h`) y el puerto `61h`. Recibe el tono en `CX` y la duración en `BX`.                                 |
| `intRand.asm`  | `int 84h`    | Devuelve en `AL` un número "aleatorio" del 0 al 9, sacado de las centésimas de segundo del reloj (`int 21h`, función `2Ch`). El jefe lo usa para decidir cuándo dispara. |

El juego en sí (`Game14h.asm`) usa:

- **BIOS `int 10h`** en modo de video `02h` (texto 80x25) para posicionar el cursor y dibujar con colores.
- **BIOS `int 16h`** para leer el teclado sin bloquear el juego. Además vacía las teclas repetidas del buffer para que la nave no se siga moviendo cuando soltás la tecla.
- **DOS `int 21h`** para mostrar textos y terminar el programa.
- **BIOS `int 15h`** (función `86h`) para las pausas que marcan la velocidad de cada nivel.
- **Sincronización con el retrazado vertical** de la VGA (puerto `3DAh`), así la pantalla se redibuja sin parpadeos.

### Compilación

`game.bat` corre dentro de DOSBox y hace todo en orden:

1. `intRand`: lo compila con `tasm /zi /m`, lo linkea como `.COM` con `tlink /t` y lo ejecuta para que quede instalada la `int 84h`.
2. `intSound`: lo mismo, para la `int 80h`.
3. `Game14h`: lo compila, lo linkea como `.EXE` con información de debug (`tlink /v`) y lo ejecuta.

Dentro de DOSBox, `TASM`, `TLINK` y `TD` (Turbo Debugger) están en el `PATH`. Para recompilar después de cambiar el código, escribir `game`. Si el teclado no anda bien, escribir `keyb sp`.
