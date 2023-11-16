using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace L5_2_D.E.T.U_1336423
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Ejercicio 2");
            Console.Write("Ingrese el número de día: ");

            try
            {
                int numeroDia = Convert.ToInt32(Console.ReadLine());

                if (numeroDia < 1 || numeroDia > 7)
                {
                    Console.WriteLine("Error: El número a ingresar debe estar contenido entre 1 y 7");
                }
                else
                {
                    if (numeroDia == 1)
                    {
                        Console.WriteLine("DIA: Lunes");
                    }
                    else if (numeroDia == 2)
                    {
                        Console.WriteLine("DIA: Martes");
                    }
                    else if (numeroDia == 3)
                    {
                        Console.WriteLine("DIA: Miércoles");
                    }
                    else if (numeroDia == 4)
                    {
                        Console.WriteLine("DIA: Jueves");
                    }
                    else if (numeroDia == 5)
                    {
                        Console.WriteLine("DIA: Viernes");
                    }
                    else if (numeroDia == 6)
                    {
                        Console.WriteLine("DIA: Sábado");
                    }
                    else
                    {
                        Console.WriteLine("DIA: Domingo");
                    }
                }
            }
            catch (FormatException)
            {
                Console.WriteLine("Error: Ingrese un número válido");
            }

            Console.ReadLine();
        }
    }
}
