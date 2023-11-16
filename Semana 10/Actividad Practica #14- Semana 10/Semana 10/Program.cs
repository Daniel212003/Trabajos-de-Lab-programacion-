using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Semana10
    {
        class Motocicleta
        {
            private int Modelo;
            private double Precio;
            private string Marca;
            private double Iva;

            public Motocicleta()
            {
                Modelo = 2019;
                Precio = 1000;
                Marca = "";
                Iva = 0.12;
            }

            public string MostrarDatos()
            {
                return $"Modelo: {Modelo}\nMarca: {Marca}\nPrecio: {Precio}\nIVA: {Iva}";
            }

            public void DefinirPrecio(double precio)
            {
                Precio = precio;
            }

            public void DefinirIva(double iva)
            {
                Iva = iva;
            }

            public double PrecioSinIva()
            {
                return Precio;
            }

            public double PrecioConIva()
            {
                return Precio * (1 + Iva);
            }

            public double DevolverIva()
            {
                return Precio * Iva;
            }
        }

        class Program
        {
            static void Main(string[] args)
            {
                Motocicleta objMotocicleta = new Motocicleta();

                Console.WriteLine("Ingrese el modelo de la motocicleta:");
                int modelo = int.Parse(Console.ReadLine());
                Console.WriteLine("Ingrese la marca de la motocicleta:");
                string marca = Console.ReadLine();
                Console.WriteLine("Ingrese el precio de la motocicleta:");
                double precio = double.Parse(Console.ReadLine());
                Console.WriteLine("Ingrese el porcentaje de IVA de la motocicleta (0.01 a 0.99):");
                double iva = double.Parse(Console.ReadLine());

                objMotocicleta.DefinirPrecio(precio);
                objMotocicleta.DefinirIva(iva);

                Console.WriteLine("\nDatos de la motocicleta:");
                Console.WriteLine(objMotocicleta.MostrarDatos());
                Console.WriteLine("\nPrecio sin IVA: " + objMotocicleta.PrecioSinIva());
                Console.WriteLine("Precio con IVA: " + objMotocicleta.PrecioConIva());
                Console.WriteLine("Monto del IVA: " + objMotocicleta.DevolverIva());

                Console.ReadLine();
            }
        }
    }

 