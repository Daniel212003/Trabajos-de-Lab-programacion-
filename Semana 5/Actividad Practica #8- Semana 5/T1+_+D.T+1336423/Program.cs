using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace T1___D.T_1336423
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Ingrese su nombre:");
            string Nombre= Console.ReadLine();
            Console.WriteLine("Ingrese su edad:");
            String Edad = Console.ReadLine();
            Console.WriteLine("Ingrese su carrera");
            String Carrera= Console.ReadLine();
            Console.WriteLine("Ingrese de numero de carnet");
            String Carnet= Console.ReadLine();

            /* COMENTARIOS */

            Console.Write(" Mi segundo programa" );
            Console.Write( " Soy " + Nombre);
            Console.Write( " tengo " + Edad+ " años ");
            Console.Write( " y estudio la carrera "  +  Carrera );
            Console.Write( " Mi numero de carnet es " +  Carnet );
            Console.ReadKey();

        }
    }
}
