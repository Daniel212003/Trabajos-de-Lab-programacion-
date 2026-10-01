# Proyecto 2 de Mecanismos: dosificador de tolva (Segundo parcial)

El mecanismo es una **manivela-corredera descentrada**: a = 35 mm, b = 132 mm, c = −20 mm y 30 rpm de diseño. Es el mismo del modelo de Inventor y del modelo impreso.

## Qué hay en cada carpeta

| Carpeta | Contenido | Incisos |
|---|---|---|
| `1_Informe/` | Informe completo en Word (editable) y PDF, de 25 páginas | h (y todos) |
| `2_MATLAB/` | Tu `Calculadora_Mecanismos.m` sin cambios, `P2_1_Calculadora_10_posiciones.m`, `P2_2_Analisis_Validacion.m`, datos de Inventor y `medicion_video.csv` | a, e, f, g |
| `2_MATLAB/Resultados_MATLAB/` | Lo que generó MATLAB: figuras, `Resultados_Parcial2.xlsx`, capturas de la calculadora y animación | e, f |
| `3_Excel/` | Tu `Calculadora velocidad.xlsx` con las hojas **P2** agregadas (fórmulas vivas y gráficas) | a, e, f, g |
| `4_Figuras/` | Figuras del informe (g1 a g4 son las del contraste experimental), fotos del modelo y `animacion_dosificador.gif` | — |
| `5_Inventor/` | `Ensamblaje.iam` y piezas | b, f |
| `6_Contraste_experimental/` | Video del modelo funcionando, captura y datos de Tracker, datos medidos cuadro por cuadro, `resultados_g.json` y `analisis_video.py` | g |

## Resultados del inciso g (video del modelo funcionando)

| Magnitud | Teórico | Medido |
|---|---|---|
| Velocidad del motor | 30 rpm (diseño) | 43.42 ± 1.03 rpm (4 vueltas); Tracker: 45.5 rpm |
| Punto muerto interior d mín | 94.92 mm | 94.92 ± 0.73 mm |
| Posición del bloque d(θ₂), 127 cuadros | curva teórica | error RMS 1.77 mm (2.5 % de la carrera) |
| Velocidad pico del bloque, retorno / avance (a la velocidad medida) | −173.4 / 160.1 mm/s | −179.5 / 153.7 mm/s |
| Biela b / manivela a | 132 / 35 mm | 132.2 / 34.1 mm |

Las fuentes principales de diferencia son tres:
- **El motor sin control de velocidad.** Gira 45 % más rápido que el diseño y su velocidad fluctúa ±14 % dentro de cada vuelta por la carga.
- **Las holguras.** Dejan unos 1.6 mm de juego al invertir el movimiento.
- **Las tolerancias.** Su efecto es menor.

## Lo que falta completar (resaltado en amarillo en el Word)

1. **Inciso d)**: la tabla de mediciones de rpm con su instrumento (por ejemplo, el tacómetro). Como referencia, el video da 43.4 rpm. En MATLAB van en `rpm_medidas` de `P2_2_Analisis_Validacion.m`.
2. **Modelo y voltaje nominal del motor** (inciso c).
3. **Nombres y carnés del grupo** en la portada.

## Cómo volver a generar los resultados

**MATLAB** (abrir la carpeta `2_MATLAB` y correr en orden):
1. `P2_1_Calculadora_10_posiciones.m`: corre tu calculadora en las 10 posiciones y guarda capturas, exportaciones y la animación.
2. `P2_2_Analisis_Validacion.m`: síntesis, 10 posiciones, simulación numérica, comparación con Inventor y con la calculadora, tabla de % de error, gráficas y el contraste con `medicion_video.csv`. Todo se guarda en `Resultados_MATLAB/`.

**Video (inciso g)**: en `6_Contraste_experimental` correr `python analisis_video.py video_modelo_funcionando.mp4`. Necesita ffmpeg, numpy, opencv-python y matplotlib. Rehace el seguimiento cuadro por cuadro, `resultados_g.json` y las figuras g1 a g4.

## Excel

Se abre en la hoja `P2 Indice`. Las celdas amarillas son datos que puedes cambiar, las grises son fórmulas y las lilas son valores importados de MATLAB, Inventor o del video. Las hojas originales (Fila 1 a 5, Calculadora y Tabla) no se tocaron.
