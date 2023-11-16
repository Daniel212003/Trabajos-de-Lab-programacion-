using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Proyecto_Programacion_Intro
{
    public class Jugador

    {
        static void MostrarTabla(string nombreMazo, string columna1, string columna2, string columna3, string columna4, string columna5, string columna6, ref double totalPuntosVida, ref double totalDaño, ref double totalElixir, params Carta[] cartas)
        {
            Console.WriteLine($"{nombreMazo}");
            Console.WriteLine($"{columna1,-20}{columna2,-20}{columna3,-20}{columna4,-20}{columna5,-20}{columna6,-20}");
            foreach (var carta in cartas)
            {
                MostrarFila(carta);
                AddCard(ref totalPuntosVida, ref totalDaño, ref totalElixir, carta);
            }
            Console.WriteLine();
        }
        static void AddCard(ref double totalPuntosVida, ref double totalDaño, ref double totalElixir, Carta carta)
        {
            totalPuntosVida += carta.Vida;
            totalDaño += carta.Daño;
            totalElixir += carta.Elixir;
        }
        static void MostrarFila(Carta carta)
        {
            Console.WriteLine($"{carta.Nombre,-20}{carta.Nivel,-20}{carta.Daño,-20}{carta.Vida,-20}{carta.Dps,-20}{carta.Elixir,-20}");
        }


        public string Nombre { get; private set; }
        public string Mazo { get; private set; }
        public double TotalPuntosVida { get; private set; }
        public double TotalDaño { get; private set; }
        public int TotalElixir { get; internal set; }

        public Jugador(string nombre, string mazoSeleccionado, double totalPuntosVida1, double totalPuntosVida2, double totalPuntosVida3, double totalPuntosVida4, double totalDaño1, double totalDaño2, double totalDaño3, double totalDaño4)
        {
            Nombre = nombre;
            Mazo = mazoSeleccionado;

            switch (mazoSeleccionado)
            {
                case "Hog 2.6 Cycle":
                    TotalPuntosVida = totalPuntosVida1;
                    TotalDaño = totalDaño1;
                    break;
                case "Giant Mortar":
                    TotalPuntosVida = totalPuntosVida2;
                    TotalDaño = totalDaño2;
                    break;
                case "Xbow 2.9":
                    TotalPuntosVida = totalPuntosVida3;
                    TotalDaño = totalDaño3;
                    break;
                case "Spell Bait":
                    TotalPuntosVida = totalPuntosVida4;
                    TotalDaño = totalDaño4;
                    break;
                default:
                    Console.WriteLine("Error del sistema: mazo no reconocido.");
                    break;
            }
        }

        public override string ToString()
        {
            if (Nombre == "iAmJP")
            {
                return $"El jugador: {Nombre} jugará en la CRL con un mazo {Mazo} que contiene un total de {TotalPuntosVida} puntos de vida.";
            }
            else
            {
                return $"El jugador: {Nombre} jugará en la CRL con un mazo {Mazo} que contiene un total de {TotalDaño} puntos de daño."

                    + $"              " + $"Clic para continuar :)";
            }

        }
        static void ImprimirTotales(double totalPuntosVida, double totalDaño, double totalElixir)
        {
            Console.WriteLine($"Total Puntos de Vida: {totalPuntosVida}");
            Console.WriteLine($"Total Daño: {totalDaño}");
            Console.WriteLine($"Promedio de Elixir: {totalElixir / 8}");
            Console.WriteLine();
        }


        internal static string MostrarDetallesMazo(string mazoSeleccionado, double totalPuntosVida1, double totalPuntosVida2, double totalPuntosVida3, double totalPuntosVida4, double totalDaño1, double totalDaño2, double totalDaño3, double totalDaño4, double totalElixir1, double totalElixir2, double totalElixir3, double totalElixir4)
        {
            StringBuilder detalles = new StringBuilder();

            switch (mazoSeleccionado)
            {
                case "Hog 2.6 Cycle":
                    detalles.AppendLine("Detalles del Mazo Hog 2.6 Cycle:");
                    Console.WriteLine("Totales del Mazo Hog 2.6 Ciclo:");
                    ImprimirTotales(totalPuntosVida1, totalDaño1, totalElixir1);
                    MostrarTabla("Mazo Hog 2.6 Cycle", "Cartas", "Unidades", "Daños", "Punto de vida", "Daños por segundo", "Promedio de elixir", ref totalPuntosVida1, ref totalDaño1, ref totalElixir1,
                    new Carta("Bola de fuego", 1, 575, 0, 0, 4),
                new Carta("El troco", 1, 290, 0, 0, 2),
                new Carta("Montapuerco", 1, 264, 1408, 165, 4),
                new Carta("Mosquetera", 1, 198, 656, 6, 4),
                new Carta("Esqueletos", 3, 153, 153, 51, 1),
                new Carta("Cañon", 1, 132, 515, 0, 3),
                new Carta("Espíritu de hielo", 1, 100, 209, 0, 1),
                new Carta("Golem de Hielo", 1, 70, 994, 28, 2)


                    );
                    break;
                case "Giant Mortar":
                    detalles.AppendLine("Detalles del Mazo Giant Mortar:");
                    Console.WriteLine("Totales del Mazo GIANT MORTAR :");
                    ImprimirTotales(totalPuntosVida2, totalDaño2, totalElixir2);
                    MostrarTabla("Mazo GIANT MORTAR", "Cartas", "Unidades", "Daños", "Punto de vida", "Daños por segundo", "Promedio de elixir", ref totalPuntosVida2, ref totalDaño2, ref totalElixir2,
              new Carta("Ejercito de esqueletos", 15, 1110, 1110, 165, 3),
              new Carta("Mini PEKKA", 1, 598, 1129, 373, 4),
              new Carta("Principe", 1, 325, 1596, 232, 5),
              new Carta("Gigante", 1, 231, 3724, 154, 5),
              new Carta("Duendes con lanza", 3, 222, 363, 0, 2),
              new Carta("Mortero", 1, 200, 1032, 0, 4),
              new Carta("Bebe dragón", 1, 146, 1051, 0, 4),
              new Carta("Arqueras", 2, 194, 277, 0, 3)
                  );
                    break;
                case "Xbow 2.9":
                    detalles.AppendLine("Detalles del Mazo Xbow 2.9:");
                    Console.WriteLine("Totales del Mazo XBOW 2.9:");
                    ImprimirTotales(totalPuntosVida3, totalDaño3, totalElixir3);
                    MostrarTabla("Mazo XBOW 2.9", "Cartas", "Unidades", "Daños", "Punto de vida", "Daños por segundo", "Promedio de elixir", ref totalPuntosVida3, ref totalDaño3, ref totalElixir3,
                new Carta("Bola de fuego", 1, 575, 0, 0, 4),
                new Carta("El troco", 1, 290, 0, 0, 2),
                new Carta("Arqueras", 2, 194, 227, 0, 3),
                new Carta("Torre Tesla", 1, 158, 792, 143, 4),
                new Carta("Esqueletos", 3, 153, 153, 51, 1),
                new Carta("Espíritu de hielo", 1, 100, 209, 0, 1),
                new Carta("Golem de Hielo", 1, 70, 994, 28, 21),
                new Carta("Ballesta", 1, 34, 1330, 0, 6)
                    );
                    break;
                case "Spell Bait":
                    detalles.AppendLine("Detalles del Mazo Spell Bait:");
                    Console.WriteLine("Totales del Mazo SPELL BAIT:");
                    ImprimirTotales(totalPuntosVida4, totalDaño4, totalElixir4);
                    MostrarTabla("Mazo SPELL BAIT", "Cartas", "Unidades", "Daños", "Punto de vida", "Daños por segundo", "Promedio de elixir", ref totalPuntosVida4, ref totalDaño4, ref totalElixir4,
                new Carta("Cohete", 1, 1022, 0, 0, 6),
                new Carta("Torre infernal", 1, 640, 1320, 1600, 5),
                new Carta("Barril de duendes", 3, 435, 732, 0, 3),
                new Carta("Pandilla de duendes", 3, 435, 732, 0, 3),
                new Carta("El troco", 1, 290, 0, 0, 2),
                new Carta("Caballero", 1, 202, 1766, 168, 3),
                new Carta("Princesa", 1, 154, 237, 51, 3),
                new Carta("Espíritu de hielo", 1, 100, 209, 0, 1)

                    );
                    break;
                default:
                    detalles.AppendLine("Error del sistema: mazo no reconocido.");
                    break;
            }

            return detalles.ToString();
        }




    }
}
