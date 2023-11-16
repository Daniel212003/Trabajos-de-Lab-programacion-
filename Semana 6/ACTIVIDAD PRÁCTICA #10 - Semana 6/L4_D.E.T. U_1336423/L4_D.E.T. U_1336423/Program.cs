using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace L4_D.E.T.U_1336423
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Ejercicio 1: Operaciones Aritméticas");

            Console.Write("Ingrese el primer número: ");
            float numero1 = float.Parse(Console.ReadLine());

            Console.Write("Ingrese el segundo número: ");
            float numero2 = float.Parse(Console.ReadLine());

            float suma = numero1 + numero2;
            float resta = numero1 - numero2;
            float multiplicacion = numero1 * numero2;
            float division = numero1 / numero2;
            int div = (int)(numero1 / numero2);
            float mod = numero1 % numero2;

            Console.WriteLine($"{numero1} + {numero2} = {suma}");
            Console.WriteLine($"{numero1} - {numero2} = {resta}");
            Console.WriteLine($"{numero1} * {numero2} = {multiplicacion}");
            Console.WriteLine($"{numero1} / {numero2} = {division}");
            Console.WriteLine($"{numero1} div {numero2} = {div}");
            Console.WriteLine($"{numero1} mod {numero2} = {mod}");

            Console.WriteLine("                                  ");
            Console.WriteLine("Ejercicio 2: Operaciones Booleanas");


            bool mayorQue = numero1 > numero2;
            bool menorQue = numero1 < numero2;
            bool igualdad = numero1 == numero2;


            Console.WriteLine($"{numero1} > {numero2} = {mayorQue}");
            Console.WriteLine($"{numero1} < {numero2} = {menorQue}");
            Console.WriteLine($"{numero1} == {numero2} = {igualdad}");

            Console.WriteLine("                                     ");
            Console.WriteLine("Ejercicio 3: Jerarquía de operaciones");

            Console.Write("Ingrese el primer número: ");
            float numero3 = float.Parse(Console.ReadLine());

            Console.Write("Ingrese el segundo número: ");
            float numero4 = float.Parse(Console.ReadLine());

            Console.Write("Ingrese el tercer número: ");
            float numero5 = float.Parse(Console.ReadLine());

            float operacion1 = (numero3 * numero4) + numero5;
            float operacion2 = numero3 * (numero4 + numero5);
            float operacion3 = numero3 / (numero4 * numero5);
            float operacion4 = (3 * numero3 + 2 * numero4) / (numero5 * numero5);


            Console.WriteLine($"{numero3} * {numero4} + {numero5}= {operacion1}");
            Console.WriteLine($"{numero3} * ({numero4} + {numero5})= {operacion2}");
            Console.WriteLine($"{numero3} / ({numero4} * {numero5})= {operacion3}");
            Console.WriteLine($"({3 * numero3} + {2 * numero4})/ {numero5 * numero5}= {operacion4}");

            Console.WriteLine("                             ");
            Console.WriteLine("Ejercicio 4: Expresión cuadrática");

            if (numero3 != 0)
            {
                double discriminante = numero4 * numero4 - 4 * numero3 * numero5;
                if (discriminante >= 0)
                {
                    double solucion1  = (-numero4 + Math.Sqrt(discriminante)) / (2 * numero3);
                    double solucion2 = (-numero4 - Math.Sqrt(discriminante)) / (2 * numero3);
                    Console.WriteLine($"Las soluciones son: solucion 1 = {solucion1} y solucion 2 = {solucion2}");
                }
                else
                {
                    Console.WriteLine("Error: El discriminante es negativo");
                }
            }
            else
            {
                Console.WriteLine("Error nuemoro 3 debe ser diferente de cero.");
            }


            Console.ReadKey();


        }
            


            
           
        }
        

    }

