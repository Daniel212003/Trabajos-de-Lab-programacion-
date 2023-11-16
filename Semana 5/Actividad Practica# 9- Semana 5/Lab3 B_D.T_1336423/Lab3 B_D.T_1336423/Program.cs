using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Lab3_B_D.T_1336423
{
    internal class Program
    {
        static void Main(string[] args)
        {
            //Cantidad de respuesta correcta, incorrectas y en blanco.
            Console.Write("Nombre del estudiante:");
            string Nombre=Console.ReadLine();   
            Console.Write("Cantidad de respuestas correctas:");
            int Correctas= Convert.ToInt32(Console.ReadLine());
            Console.Write("Cantidad de respuestas incorrectas:");
            int Incorrectas= Convert.ToInt32(Console.ReadLine());
            Console.Write("Cantidad de respuestas en blanco: ");
            int Blanco= Convert.ToInt32(Console.ReadLine());

            // Calculamos el puntaje final
            int puntajeFinal = (Correctas * 5) - (Incorrectas * 1) - ( Blanco * 0 );

            //Muestra de nota final
            Console.WriteLine($" La nota final del estudiante {Nombre} es {puntajeFinal} puntos ");
            
            Console.ReadKey();
        }
    }
}
