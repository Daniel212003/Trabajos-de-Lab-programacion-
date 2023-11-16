using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace T4_D.E.T.U_1336423_E1
{
    internal class Program
    {
        static void Main(string[] args)
        {
          
            Console.WriteLine("Movimiento rectilíneo uniformemente ");
            Console.WriteLine("Ingrese solamente 3 datos");
            Console.WriteLine("Ingrese Velocidad Final");
            string VFinalInput = Console.ReadLine();
            Console.WriteLine("Ingrese velocidad Inicial");
            string VInicialInput = Console.ReadLine();
            Console.WriteLine("Ingrese tiempo");
            string tiempoInput = Console.ReadLine();
            Console.WriteLine("Ingrese aceleración");
            string aceleracionInput = Console.ReadLine();

            int variablesIngresadas = 0;

            if (!string.IsNullOrEmpty(VFinalInput)) { variablesIngresadas++; }
            if (!string.IsNullOrEmpty(VInicialInput)) { variablesIngresadas++; }
            if (!string.IsNullOrEmpty(tiempoInput)) { variablesIngresadas++; }
            if (!string.IsNullOrEmpty(aceleracionInput)) { variablesIngresadas++; }

            if (variablesIngresadas != 3)
            {
                Console.WriteLine("Debe ingresar exactamente 3 valores.");
            }

            else
            {
                double VFinal = 0, VInicial = 0, tiempo = 0, aceleracion = 0;

                if (string.IsNullOrEmpty(VFinalInput))
                {
                    VFinal = double.Parse(VInicialInput) + double.Parse(aceleracionInput) * double.Parse(tiempoInput);
                    Console.WriteLine($"La Velocidad Final es de = {VFinal}");
                }
                if (string.IsNullOrEmpty(VInicialInput))
                {
                    VInicial = double.Parse(VFinalInput) - double.Parse(aceleracionInput) * double.Parse(tiempoInput);
                    Console.WriteLine($"La Velocidad Inicial es de = {VInicial}");
                }
                if (string.IsNullOrEmpty(aceleracionInput))
                {
                    aceleracion = (double.Parse(VFinalInput) - double.Parse(VInicialInput)) / double.Parse(tiempoInput);
                    Console.WriteLine($"La aceleración es de = {aceleracion}");
                }
                if (string.IsNullOrEmpty(tiempoInput))
                {
                    tiempo = (double.Parse(VFinalInput) - double.Parse(VInicialInput)) / double.Parse(aceleracionInput);
                    Console.WriteLine($"El tiempo es de  = {tiempo}");
                }
            }

            Console.ReadKey();
        
    }
    }
}
