using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Tarea_2.Lab5__D.E.T.U_1336423
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Ingrese el monto de la compra:");
            decimal monto;
            while (!decimal.TryParse(Console.ReadLine(), out monto))
            {
                Console.WriteLine("Ingrese un valor numérico válido.");
            }

            Console.WriteLine("Ingrese el código de descuento :");
            string codigoDescuento = Console.ReadLine();

            decimal descuento = 0;

            if (monto < 400)
            {
                descuento = 0;
            }
            else if (monto >= 400 && monto <= 1000)
            {
                descuento = monto * 0.07m;
            }
            else if (monto > 1000 && monto <= 5000)
            {
                descuento = monto * 0.10m;
            }
            else if (monto > 5000 && monto <= 15000)
            {
                descuento = monto * 0.15m;
            }
            else if (monto > 15000)
            {
                descuento = monto * 0.25m;
            }

            if (!string.IsNullOrEmpty(codigoDescuento))
            {
                descuento += monto * 0.05m;
            }

            decimal montoFinal = monto - descuento;

            Console.WriteLine("Monto a pagar final: {0:F2}", montoFinal);

            Console.ReadKey();
        }
    }
}
