using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace L7_D.E.T.U_1336423
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine(" Ingese su nombre. ");
            string Nombre = Console.ReadLine();
            Console.WriteLine(" Ingese su numeor de carnet");
            string Carnet = Console.ReadLine();
            Console.WriteLine("Ingrese un número entero positivo :");
            int n;

            while (true)
            {
                if (int.TryParse(Console.ReadLine(), out n) && n > 0)
                {
                    break;
                }
                else
                {
                    Console.WriteLine("Por favor, ingrese un número entero mayor a 0.");
                }
            }

            Console.WriteLine($"La suma de la serie a {n} es: {CalcularSerieA(n)}");
            Console.WriteLine($"La suma de la serie b {n} es: {CalcularSerieB(n)}");

            Console.WriteLine("Ingrese el valor de x:");
            int x;

            while (true)
            {
                if (int.TryParse(Console.ReadLine(), out x))
                {
                    break;
                }
                else
                {
                    Console.WriteLine("Por favor, ingrese un número entero válido para x.");
                }
            }

            Console.WriteLine("Ingrese el valor de a:");
            int a;

            while (true)
            {
                if (int.TryParse(Console.ReadLine(), out a))
                {
                    break;
                }
                else
                {
                    Console.WriteLine("Por favor, ingrese un número entero válido para a.");
                }
            }

            Console.WriteLine("Ingrese el valor de n:");
            int n2;

            while (true)
            {
                if (int.TryParse(Console.ReadLine(), out n2) && n2 > 0)
                {
                    break;
                }
                else
                {
                    Console.WriteLine("Por favor, ingrese un número entero positivo.");
                }
            }

            Console.WriteLine($"La suma de la serie C {n2} es: {CalcularSerieC(x, a, n2)}");

            Console.WriteLine("Presione cualquier tecla para salir.");
            Console.ReadKey();
        }

        static double CalcularSerieA(int n)
        {
            double resultado = 0.0;

            for (int i = 1; i <= n; i++)
            {
                resultado += 1.0 / i;
            }

            return resultado;
        }

        static double CalcularSerieB(int n)
        {
            double resultado = 0.0;

            for (int i = 1; i <= n; i++)
            {
                resultado += 1.0 / Math.Pow(2, i);
            }

            return resultado;
        }

        static double CalcularSerieC(int x, int a, int n)
        {
            double resultado = 0.0;

            for (int k = 0; k <= n; k++)
            {
                resultado += Math.Pow(x, k) * Math.Pow(a, n - k) / Factorial(k) / Factorial(n - k);
            }

            return resultado;
        }

        static int Factorial(int num)
        {
            if (num == 0 || num == 1)
            {
                return 1;
            }
            else
            {
                return num * Factorial(num - 1);



            }
        }
    }
}
