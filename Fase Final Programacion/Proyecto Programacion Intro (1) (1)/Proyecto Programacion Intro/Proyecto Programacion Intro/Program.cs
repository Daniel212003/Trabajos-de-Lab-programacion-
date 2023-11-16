using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Proyecto_Programacion_Intro
{
    internal class Program
    {
        static void Main(string[] args)
        {
            string nombreJugador2;
            string equipoJugador2;

            Console.WriteLine("Ingrese el nombre del primer jugador, puede ser iAmJP o Mohamed Light:");
            string nombreJugador1 = Console.ReadLine();

            Console.WriteLine("Ingrese el equipo al que pertenece el primer jugador, Team Queso o Golden Wing:");
            string equipoJugador1 = Console.ReadLine();

            

            if (nombreJugador1.Equals("iAmJP", StringComparison.OrdinalIgnoreCase))
            {
                nombreJugador2 = "Mohamed Light";
            }
            else if (nombreJugador1.Equals("Mohamed Light", StringComparison.OrdinalIgnoreCase))
            {
                nombreJugador2 = "iAmJP";
            }
            else
            {
                Console.WriteLine("Error: El nombre del primer jugador no es válido.");
                Console.ReadKey();
                return;
            }

            if (equipoJugador1.Equals("Team Queso", StringComparison.OrdinalIgnoreCase))
            {
                equipoJugador2 = "Golden Wing";
            }
            else if (equipoJugador1.Equals("Golden Wing", StringComparison.OrdinalIgnoreCase))
            {
                equipoJugador2 = "Team Queso";
            }
            else
            {
                Console.WriteLine("Error: El equipo del primer jugador no es válido.");
                Console.ReadKey();
                return;
            }

            string abreviaturaJugador1 = ObtenerAbreviatura(nombreJugador1, equipoJugador1);
            string nickNameJugador1 = abreviaturaJugador1;

            string abreviaturaJugador2 = ObtenerAbreviatura(nombreJugador2, equipoJugador2);


            string nickNameJugador2 = abreviaturaJugador2;
            double totalPuntosVida1 = 0, totalDaño1 = 0, totalElixir1 = 0;
            double totalPuntosVida2 = 0, totalDaño2 = 0, totalElixir2 = 0;
            double totalPuntosVida3 = 0, totalDaño3 = 0, totalElixir3 = 0;
            double totalPuntosVida4 = 0, totalDaño4 = 0, totalElixir4 = 0;
            Console.WriteLine($"El nombre del apodo del jugador 1 es: {nickNameJugador1}");
            Console.WriteLine($"El nombre del apodo del jugador 2 es: {nickNameJugador2}");

            Console.WriteLine("----------------------------------------------------- -------------------------------------------------- -------------");
            Console.WriteLine(" ");
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
            Console.WriteLine("----------------------------------------------------- -------------------------------------------------- -------------");
            Console.WriteLine(" ");
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
            Console.WriteLine("----------------------------------------------------- -------------------------------------------------- -------------");
            Console.WriteLine(" ");
            MostrarTabla("Mazo XBOW 2.9", "Cartas", "Unidades", "Daños", "Punto de vida", "Daños por segundo", "Promedio de elixir", ref totalPuntosVida3, ref totalDaño3, ref totalElixir3,
                new Carta("Bola de fuego", 1, 575, 0, 0, 4),
                new Carta("El troco", 1, 290, 0, 0, 2),
                new Carta("Arqueras", 2, 194, 227, 0, 3),
                new Carta("Torre Tesla", 1, 158, 792, 143, 4),
                new Carta("Esqueletos", 3, 153, 153, 51, 1),
                new Carta("Espíritu de hielo", 1, 100, 209, 0, 1),
                new Carta("Golem de Hielo", 1, 70, 994, 28, 2),
                new Carta("Ballesta", 1, 34, 1330, 0, 6)
            );
            Console.WriteLine("----------------------------------------------------- -------------------------------------------------- -------------");
            Console.WriteLine(" ");
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
            Console.WriteLine("Totales del Mazo Hog 2.6 Ciclo:");
            ImprimirTotales(totalPuntosVida1, totalDaño1, totalElixir1);

            Console.WriteLine("Totales del Mazo GIANT MORTAR :");
            ImprimirTotales(totalPuntosVida2, totalDaño2, totalElixir2);

            Console.WriteLine("Totales del Mazo XBOW 2.9:");
            ImprimirTotales(totalPuntosVida3, totalDaño3, totalElixir3);

            Console.WriteLine("Totales del Mazo SPELL BAIT:");
            ImprimirTotales(totalPuntosVida4, totalDaño4, totalElixir4);

            string mazoSeleccionadoA = SeleccionarMazo("iAmJP", totalPuntosVida1, totalPuntosVida2, totalPuntosVida3, totalPuntosVida4);
            string mazoSeleccionadoB = SeleccionarMazo("Mohamed Light", totalDaño1, totalDaño2, totalDaño3, totalDaño4);

            Jugador jugador1 = new Jugador("iAmJP", mazoSeleccionadoA, totalPuntosVida1, totalPuntosVida2, totalPuntosVida3, totalPuntosVida4, totalDaño1, totalDaño2, totalDaño3, totalDaño4);
            Jugador jugador2 = new Jugador("Mohamed Light", mazoSeleccionadoB, totalPuntosVida1, totalPuntosVida2, totalPuntosVida3, totalPuntosVida4, totalDaño1, totalDaño2, totalDaño3, totalDaño4);
            Console.WriteLine(jugador1);
            Console.WriteLine(jugador2);
            Console.ReadKey();

            Console.WriteLine(" ");
            Console.WriteLine("----------------------------------------------------------------------------------------------------------------------");
            string detallesMazoA = Jugador.MostrarDetallesMazo(jugador1.Mazo, totalPuntosVida1, totalPuntosVida2, totalPuntosVida3, totalPuntosVida4, totalDaño1, totalDaño2, totalDaño3, totalDaño4, totalElixir1, totalElixir2, totalElixir3, totalElixir4);
            Console.WriteLine(detallesMazoA);
            Console.WriteLine(" ");
            Console.WriteLine("-----------------------------------------------------------------------------------------------------------------------");

            string detallesMazoB = Jugador.MostrarDetallesMazo(jugador2.Mazo, totalPuntosVida1, totalPuntosVida2, totalPuntosVida3, totalPuntosVida4, totalDaño1, totalDaño2, totalDaño3, totalDaño4, totalElixir1, totalElixir2, totalElixir3, totalElixir4);
            Console.WriteLine(detallesMazoB);


            string mazoGanadorDaño = "";



            if (jugador1.TotalDaño > jugador2.TotalDaño)
            {
                Console.WriteLine($"{jugador1.Nombre} gana en puntos de daño con el mazo {mazoSeleccionadoA}.");
                mazoGanadorDaño = mazoSeleccionadoA;
            }
            else if (jugador1.TotalDaño < jugador2.TotalDaño)
            {
                Console.WriteLine($"{jugador2.Nombre} gana en puntos de daño con el mazo {mazoSeleccionadoB}.");
                mazoGanadorDaño = mazoSeleccionadoB;
            }
            else
            {
                Console.WriteLine("Empate en puntos de daño.");
            }


            string mazoGanadorPartida = "";

            if (mazoGanadorDaño == mazoSeleccionadoA)
            {
                mazoGanadorPartida = mazoGanadorDaño;
                Console.WriteLine($"¡Felicidades el jugador {jugador1.Nombre} con el mazo {mazoGanadorPartida} es el ganador general de la partida!");
            }
            else if (mazoGanadorDaño == mazoSeleccionadoB)
            {
                mazoGanadorPartida = mazoGanadorDaño;
                Console.WriteLine($"¡Felicidades el jugador {jugador2.Nombre} con el mazo {mazoGanadorPartida} es el ganador general de la partida!");
            }

            else
            {
                Console.WriteLine("Empate en puntos de daño.");
            }




            Console.ReadKey();


        }

        static string SeleccionarMazo(string jugador, double total1, double total2, double total3, double total4)
        {
            string mazoSeleccionado = "";

            if (total1 > total2 && total1 > total3 && total1 > total4)
            {
                mazoSeleccionado = "Hog 2.6 Cycle";
            }
            else if (total2 > total1 && total2 > total3 && total2 > total4)
            {
                mazoSeleccionado = "Giant Mortar";
            }
            else if (total3 > total1 && total3 > total2 && total3 > total4)
            {
                mazoSeleccionado = "Xbow 2.9";
            }
            else if (total4 > total1 && total4 > total2 && total4 > total3)
            {
                mazoSeleccionado = "Spell Bait";
            }

            return mazoSeleccionado;
        }

        static string ObtenerAbreviatura(string nombreJugador, string equipo)
        {
            string abreviaturaEquipo = (equipo.ToLower() == "team queso") ? "TQ" : ((equipo.ToLower() == "golden wing") ? "GW" : "NA");

            string[] palabrasNombre = nombreJugador.Split(' ');
            string abreviaturaNombre = (palabrasNombre.Length > 1) ? palabrasNombre[0] + palabrasNombre[1] : nombreJugador;

            int numero = (abreviaturaNombre == "MohamedLight") ? 6 : nombreJugador.Length - 1;

            int indice = nombreJugador.IndexOf(nombreJugador[0]);

            string abreviaturaCompleta = $"{abreviaturaEquipo} - {abreviaturaNombre}{numero}{indice}";

            return abreviaturaCompleta;
        }

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

        static void MostrarFila(Carta carta)
        {
            Console.WriteLine($"{carta.Nombre,-20}{carta.Nivel,-20}{carta.Daño,-20}{carta.Vida,-20}{carta.Dps,-20}{carta.Elixir,-20}");
        }

        static void AddCard(ref double totalPuntosVida, ref double totalDaño, ref double totalElixir, Carta carta)
        {
            totalPuntosVida += carta.Vida;
            totalDaño += carta.Daño;
            totalElixir += carta.Elixir;
        }

        static void ImprimirTotales(double totalPuntosVida, double totalDaño, double totalElixir)
        {
            Console.WriteLine($"Total Puntos de Vida: {totalPuntosVida}");
            Console.WriteLine($"Total Daño: {totalDaño}");
            Console.WriteLine($"Promedio de Elixir: {totalElixir / 8}");
            Console.WriteLine();
        }
    
}
}
