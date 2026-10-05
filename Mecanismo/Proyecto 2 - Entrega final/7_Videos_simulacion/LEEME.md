# Videos de simulación: usos del dosificador

Hay cuatro videos (1280 × 720, 30 fps) y un compilado. Muestran el mecanismo del proyecto (manivela-corredera descentrada: a = 35 mm, b = 132 mm, c = −20 mm, 30 rpm) en aplicaciones reales. Cada uno está montado dentro de un levantamiento 3D de la planta (nube de puntos), al estilo de un estudio de distribución de planta.

| Video | Uso | Escala | Qué muestra |
|---|---|---|---|
| `0_Compilado_usos_del_dosificador.mp4` | Los cuatro seguidos | — | Para presentar el proyecto |
| `1_Gemelo_digital.mp4` | Gemelo digital del modelo construido | 1:1 | Las piezas de los planos; trazas del pasador A (círculo), del punto medio de la biela (curva de acoplador) y del pasador B; cotas a, b, c; punto muerto interior; avance y retorno; V_B en vivo |
| `2_Empaque_de_cafe.mp4` | Industria alimentaria: llenado de bolsas | 1:1 | La tolva recorrida 67 mm (recomendación del informe), la compuerta h = 31 mm y la dosis de 200 g por vuelta. La banda avanza una bolsa en cada retorno |
| `3_Planta_de_alimento_balanceado.mp4` | Ensacado bajo un silo | ×4 | 10 kg por vuelta; 4 vueltas llenan un saco de 40 kg; 300 kg/min ≈ 18 t/h a 30 rpm |
| `4_Linea_de_ensamble.mp4` | Transferidor de cajas entre dos bandas | ×3 | Una caja por vuelta, 30 cajas/min; la carrera de 212.6 mm pasa la caja de un carril al otro |

## Qué es exacto y qué es ilustrativo

- **Exacto.** La posición de la manivela, la biela y el bloque en cada cuadro sale de las ecuaciones cerradas de Norton (rama abierta), las mismas del informe y de la calculadora. El avance (185°), el retorno (175°), los puntos muertos y V_B coinciden con los resultados del inciso e. En las versiones ×3 y ×4 las longitudes y velocidades se multiplican por la escala, pero los ángulos, Q y μ no cambian.
- **Simplificado.** El flujo del material es un modelo de flujo tapón: la capa de altura h avanza con el bloque y lo que pasa el borde cae. El ambiente (nube de puntos) es generado, no es un escaneo real. Las cifras de producción son estimaciones con la densidad indicada en cada video.

## Cómo se hicieron y cómo volver a generarlos

La carpeta `fuente/` tiene una página HTML por escena (Three.js), la librería común `lib.js` y `render.js`. Este último abre cada escena en Chromium sin ventana, la dibuja cuadro por cuadro y arma el MP4 con ffmpeg. Para volver a generarlos:

```
cd fuente
npm install three@0.170.0 playwright
npx playwright install chromium
python -m http.server 8123          # en otra terminal, dentro de fuente/
node render.js A_gemelo_digital.html 1_Gemelo_digital.mp4
```

Las escenas también se pueden abrir en el navegador (con el servidor corriendo) para revisarlas. En `lib.js`, la función `buildDoser(k)` arma el dosificador con las medidas de los planos multiplicadas por la escala k, y `kinematics(k)` tiene las ecuaciones.
