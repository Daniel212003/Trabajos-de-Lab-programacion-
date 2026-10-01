# Proyecto 2 de Mecanismos: dosificador de tolva (Segundo parcial)

El mecanismo es una **manivela-corredera descentrada**: a = 35 mm, b = 132 mm, c = −20 mm y 30 rpm de diseño. Es el mismo del modelo de Inventor y del borrador anterior.

## Qué hay en cada carpeta

| Carpeta | Contenido | Incisos |
|---|---|---|
| `1_Informe/` | Informe completo en Word (editable) y PDF | h (y todos) |
| `2_MATLAB/` | Tu `Calculadora_Mecanismos.m` sin cambios, `P2_1_Calculadora_10_posiciones.m`, `P2_2_Analisis_Validacion.m`, datos de Inventor y plantilla del video | a, e, f, g |
| `2_MATLAB/Resultados_MATLAB/` | Lo que generó MATLAB: figuras, `Resultados_Parcial2.xlsx`, capturas de la calculadora y animación | e, f |
| `3_Excel/` | Tu `Calculadora velocidad.xlsx` con las hojas **P2** agregadas (fórmulas vivas y gráficas) | a, e, f, g |
| `4_Figuras/` | Figuras del informe y `animacion_dosificador.gif` para la presentación | — |
| `5_Inventor/` | `Ensamblaje.iam` y piezas | b, f |

## Lo que falta completar (resaltado en amarillo en el Word)

1. **Inciso d)**: las 3 mediciones de rpm con su instrumento.
   - En el Excel van en la hoja `P2 g) Contraste`, celdas amarillas C6 a C9.
   - En MATLAB van en la variable `rpm_medidas` de `P2_2_Analisis_Validacion.m`.
2. **Inciso g)**: lo que midan en el modelo físico. Son la carrera con vernier, la posición del bloque en θ₂ = 90°, la velocidad máxima y el periodo.
   - Se escriben en la hoja `P2 g) Contraste`, y las diferencias se calculan solas.
   - Si graban video y lo analizan en Tracker, guarden el resultado como `2_MATLAB/medicion_video.csv` (columnas `t,x`, ver la plantilla) y corran `P2_2`. Eso genera la gráfica de contraste.
3. Fotos del modelo impreso y del motor funcionando (incisos b y c), modelo y par del motor.
4. Nombres y carnés del grupo en la portada.

## Cómo volver a generar los resultados en MATLAB

Abre la carpeta `2_MATLAB` en MATLAB y corre los scripts en este orden:

1. `P2_1_Calculadora_10_posiciones.m`: abre tu calculadora, la pone en las 10 posiciones y guarda capturas, exportaciones y la animación.
2. `P2_2_Analisis_Validacion.m`: síntesis, 10 posiciones, simulación numérica, comparación con Inventor y con la calculadora, tabla de % de error, gráficas y Excel de resultados.

Todo se guarda en `Resultados_MATLAB/`.

## Excel

Se abre en la hoja `P2 Indice`. Las celdas amarillas son datos que puedes cambiar, las grises son fórmulas y las lilas son valores importados de MATLAB e Inventor. Las hojas originales (Fila 1 a 5, Calculadora y Tabla) no se tocaron.
