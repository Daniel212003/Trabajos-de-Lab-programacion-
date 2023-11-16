using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace T4___D.E.T.U__1336423_E2
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Calculadora de Denominaciones");
            Console.WriteLine("Ingrese su nombre:");
            string Nombre= Console.ReadLine();
            Console.WriteLine("Ingrese su numero de carnet:");
            string Carnet = Console.ReadLine();Console.Write("Ingrese la cantidad en quetzales: ");
            

            double cantidadEnQuetzales;
            if (!double.TryParse(Console.ReadLine(), out cantidadEnQuetzales) || cantidadEnQuetzales < 0 || cantidadEnQuetzales > 999.99)
            {
                Console.WriteLine("Cantidad ingresada no válida. Debe estar entre 0 y 999.99 quetzales.");
                return;

            }
            int billetes100 = (int)cantidadEnQuetzales / 100;
            cantidadEnQuetzales %= 100;

            int billetes50 = (int)cantidadEnQuetzales / 50;
            cantidadEnQuetzales %= 50;

            int billetes20 = (int)cantidadEnQuetzales / 20;
            cantidadEnQuetzales %= 20;

            int billetes10 = (int)cantidadEnQuetzales / 10;
            cantidadEnQuetzales %= 10;

            int billetes5 = (int)cantidadEnQuetzales / 5;
            cantidadEnQuetzales %= 5;

            int monedas1 = (int)cantidadEnQuetzales;
            cantidadEnQuetzales -= monedas1;

            int monedas25Centavos = (int)(cantidadEnQuetzales * 4);
            cantidadEnQuetzales -= monedas25Centavos * 0.25;

            int monedas1Centavo = (int)(cantidadEnQuetzales * 100);

            // Mostrar las denominaciones
            Console.WriteLine("\nDenominaciones:");
            Console.WriteLine($"Billetes de 100 quetzales son {billetes100}");
            Console.WriteLine($"Billetes de 50 quetzales son {billetes50}");
            Console.WriteLine($"Billetes de 20 quetzales son {billetes20}");
            Console.WriteLine($"Billetes de 10 quetzales son {billetes10}");
            Console.WriteLine($"Billetes de 5 quetzales son {billetes5}");
            Console.WriteLine($"Monedas de 1 quetzal son {monedas1}");
            Console.WriteLine($"Monedas de 25 centavos son {monedas25Centavos}");
            Console.WriteLine($"Monedas de 1 centavo son {monedas1Centavo}");
        Console.ReadKey();
        }
    }
}
