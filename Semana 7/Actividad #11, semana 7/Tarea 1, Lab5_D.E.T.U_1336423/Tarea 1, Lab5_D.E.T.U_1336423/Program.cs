using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Tarea_1__Lab5_D.E.T.U_1336423
{
    internal class Program
    {
        static void Main(string[] args)
        {
            decimal[] cantidades = new decimal[3];
            string[] monedas = new string[3];
            decimal tipoCambio = 7.83m;

            for (int i = 0; i < 3; i++)
            {
                Console.WriteLine("Ingrese la cantidad No. {0}:", i + 1);
                while (!decimal.TryParse(Console.ReadLine(), out cantidades[i]))
                {
                    Console.WriteLine("Ingrese un valor numérico válido.");
                }

                Console.WriteLine("USD o GTQ?");
                while (true)
                {
                    string input = Console.ReadLine().ToUpper();
                    if (input == "USD" || input == "GTQ")
                    {
                        monedas[i] = input;
                        break;
                    }
                    else
                    {
                        Console.WriteLine("Ingrese 'USD' o 'GTQ'.");
                    }
                }
            }

            Console.WriteLine("Resultado:");

            for (int i = 0; i < 3; i++)
            {
                if (monedas[i] == "USD")
                {
                    decimal cantidadEnQuetzales = cantidades[i] * tipoCambio;
                    Console.WriteLine("{0:F2} GTQ", cantidadEnQuetzales);
                }
                else if (monedas[i] == "GTQ")
                {
                    Console.WriteLine("{0:F2} GTQ", cantidades[i]);
                }
            }

            Console.ReadKey();
        }
    }
}
