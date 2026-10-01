# Proyecto 2 de Mecanismos: dosificador de tolva (Segundo parcial)

El mecanismo es una **manivela-corredera descentrada**: a = 35 mm, b = 132 mm, c = −20 mm y 30 rpm de diseño. Es el mismo del modelo de Inventor y del modelo impreso, y coincide con los planos de las piezas (`5_Inventor/Dimensiones_de_piezas.pdf`). El motor es un motorreductor de CD de 3–6 V y 120 rpm nominales, con engranajes metálicos.

## Qué hay en cada carpeta

| Carpeta | Contenido | Incisos |
|---|---|---|
| `1_Informe/` | Informe completo en Word (editable) y PDF, de 38 páginas; el Anexo D trae los planos de las piezas | h (y todos) |
| `2_MATLAB/` | Tu `Calculadora_Mecanismos.m` sin cambios, `P2_1_Calculadora_10_posiciones.m`, `P2_2_Analisis_Validacion.m`, datos de Inventor y `medicion_video.csv` | a, e, f, g |
| `2_MATLAB/Resultados_MATLAB/` | Lo que generó MATLAB: figuras, `Resultados_Parcial2.xlsx`, capturas de la calculadora y animación | e, f |
| `3_Excel/` | Tu `Calculadora velocidad.xlsx` con las hojas **P2** agregadas (fórmulas vivas y gráficas) | a, b, c, e, f, g |
| `4_Figuras/` | Figuras del informe (g1 a g4 son las del contraste experimental; `fig_c_desde_planos.png` muestra de dónde salen a, b y c), fotos del modelo y `animacion_dosificador.gif` | — |
| `5_Inventor/` | `Ensamblaje.iam`, piezas y `Dimensiones_de_piezas.pdf` (planos de cada pieza) | b, f |
| `6_Contraste_experimental/` | Video del modelo funcionando, captura y datos de Tracker, datos medidos cuadro por cuadro, `resultados_g.json` y `analisis_video.py` | g |

## Dimensiones reales (planos de las piezas)

Revisé las 8 hojas de `Dimensiones_de_piezas.pdf`. Las tres medidas que usa el cálculo son las del modelo real:

| Dato | De dónde sale | Plano | Cálculo |
|---|---|---|---|
| Manivela a | agujero del disco-manivela a 35 mm del centro (hoja 2) | 35.0 mm | 35 mm |
| Biela b | distancia entre centros de la biela (hoja 3) | 132.0 mm | 132 mm |
| Descentrado c | pasador B a 35 + 30/2 = 50.0 mm sobre la placa (oreja del bloque, hoja 4), menos el eje O₂ a 70.0 mm (agujero del soporte, hoja 1) | −20.0 mm | −20 mm |

**Por eso no cambia ningún resultado** de los incisos a, e y f. Lo nuevo que aportan los planos está en el informe (sección 4.1) y en la hoja `P2 b-c) Piezas y motor` del Excel:
- **Holguras.** Pasadores de Ø 14.5 en agujeros de Ø 15, o sea 0.5 mm por junta en O₂, A y B. Predicen hasta 1.5 mm de juego; en el video se midieron 1.55 mm.
- **Masa estimada con las medidas reales.** Bloque impreso ≈ 0.60 kg más ≈ 0.36 kg de alimento en la tolva; con 25 % de margen se usa m = 1.2 kg para el par del motor.

## Motor (inciso c)

Motorreductor de CD de 3–6 V, 120 rpm nominales y engranajes metálicos. Con carga giró a 43.4 rpm, el 36 % de su velocidad nominal.

| | 30 rpm (diseño) | 43.4 rpm (medida) | 120 rpm (nominal) |
|---|---|---|---|
| max V_B | 119.8 mm/s | 173.4 mm/s | 479.2 mm/s |
| max A_B | 441 mm/s² | 925 mm/s² | 7064 mm/s² |
| Par requerido | 1.58 kgf·cm | 1.80 kgf·cm | 4.67 kgf·cm |

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

## Inciso d

Velocidad del motor medida en el video, cuadro por cuadro, con 4 vueltas completas: 43.78, 43.11, 44.10 y 42.67 rpm. El resultado es **43.42 ± 1.03 rpm** (U₉₅), con s = 0.65 rpm y CV = 1.5 %.

## Lo que falta completar (resaltado en amarillo en el Word)

1. **Nombres y carnés del grupo** en la portada.

## Cómo volver a generar los resultados

**MATLAB** (abrir la carpeta `2_MATLAB` y correr en orden):
1. `P2_1_Calculadora_10_posiciones.m`: corre tu calculadora en las 10 posiciones y guarda capturas, exportaciones y la animación.
2. `P2_2_Analisis_Validacion.m`: síntesis, 10 posiciones, simulación numérica, comparación con Inventor y con la calculadora, tabla de % de error, gráficas y el contraste con `medicion_video.csv`. Todo se guarda en `Resultados_MATLAB/`.

**Video (inciso g)**: en `6_Contraste_experimental` correr `python analisis_video.py video_modelo_funcionando.mp4`. Necesita ffmpeg, numpy, opencv-python y matplotlib. Rehace el seguimiento cuadro por cuadro, `resultados_g.json` y las figuras g1 a g4.

## Excel

Se abre en la hoja `P2 Indice`. Las celdas amarillas son datos que puedes cambiar, las grises son fórmulas y las lilas son valores importados de MATLAB, Inventor o del video. Las hojas originales (Fila 1 a 5, Calculadora y Tabla) no se tocaron.
