using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace L5_D.E.T.U_1336423
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Ejercicio 1");
            Console.Write("Número entero: ");

            try
            {
                int numero = Convert.ToInt32(Console.ReadLine());

                if (numero > 0)
                {
                    Console.WriteLine("RESULTADO: El número es positivo");
                }
                else if (numero < 0)
                {
                    Console.WriteLine("RESULTADO: El número es negativo");
                }
                else
                {
                    Console.WriteLine("RESULTADO: El número es cero");
                }
            }
            catch (FormatException)
            {
                Console.WriteLine("ERROR: Ingrese un número entero válido");
            }

            Console.ReadLine();
        }
    }
}
