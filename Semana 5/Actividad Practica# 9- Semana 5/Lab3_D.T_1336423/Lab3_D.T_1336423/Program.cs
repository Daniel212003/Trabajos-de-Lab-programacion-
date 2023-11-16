using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Lab3_D.T_1336423
{
    internal class Program
    {
        static void Main(string[] args)
        {
            //Datos Iniciales 
            Console.WriteLine("Ingrese el costo inicial del vehiculo");
            double costoInicial = double.Parse(Console.ReadLine());
            Console.WriteLine("Ingrese el numero de años de uso ");
            int añosDeUso = int.Parse(Console.ReadLine());
            Console.WriteLine("Ingrese el valor de recuperacion");
            double valorRecuperacion = double.Parse(Console.ReadLine());

            //Operacion de depresacion anual
         double depreciacionAnual = (costoInicial - valorRecuperacion) / añosDeUso;

            // Imprimimos la tabla de depreciación
            Console.WriteLine("Año\tDepreciación Anual\tValor Real");
           

            double valorActual = costoInicial;
            for (int año = 2016; año <= 2021; año++)
            {
                double depreciacionAcumulada = (año - 2016 + 1) * depreciacionAnual;
                valorActual -= depreciacionAnual;

                Console.WriteLine($"{año}\t{depreciacionAnual:C}\t{valorActual:C}");
            }

            // Imprimimos el valor de recuperación al final de la vida útil
          
            Console.WriteLine($"Valor de Recuperación en {2022}:\t{valorRecuperacion:C}");
            Console.ReadKey();

        }
    }
}
