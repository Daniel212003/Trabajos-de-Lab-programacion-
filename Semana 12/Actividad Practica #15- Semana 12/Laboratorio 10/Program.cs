using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Laboratorio_10
{
    class Circulo
    {
        private double radio;

        public Circulo(double radio)
        {
            this.radio = radio;
        }

        private double ObtenerPerimetro()
        {
            return 2 * Math.PI * radio;
        }

        private double ObtenerArea()
        {
            return Math.PI * Math.Pow(radio, 2);
        }

        private double ObtenerVolumen()
        {
            return (4 * Math.PI * Math.Pow(radio, 3)) / 3;
        }

        public void CalcularGeometria(ref double perimetro, ref double area, ref double volumen)
        {
            perimetro = ObtenerPerimetro();
            area = ObtenerArea();
            volumen = ObtenerVolumen();
        }
    }

    class TrianguloRectangulo
    {
        private double catetoA;
        private double anguloOpuestoA;

        public TrianguloRectangulo(double catetoA, double anguloOpuestoA)
        {
            this.catetoA = catetoA;
            this.anguloOpuestoA = anguloOpuestoA;
        }

        public double ObtenerCatetoA()
        {
            return catetoA;
        }

        public double ObtenerCatetoB()
        {
            double anguloRad = Math.PI * anguloOpuestoA / 180.0;
            return catetoA / Math.Tan(anguloRad);
        }

        public double ObtenerHipotenusa()
        {
            return catetoA / Math.Sin(anguloOpuestoA);
        }

        public double ObtenerAnguloOpuestoA()
        {
            return anguloOpuestoA;
        }

        public double ObtenerAnguloOpuestoB()
        {
            return 90 - anguloOpuestoA;
        }

        public double ObtenerArea()
        {
            return 0.5 * catetoA * ObtenerCatetoB();
        }
    }

    class Program
    {
        static void Main()
        {
            Console.Write("Ingrese el radio del círculo: ");
            double radio = Convert.ToDouble(Console.ReadLine());

            Circulo objCirculo = new Circulo(radio);

            double perimetro = 0, area = 0, volumen = 0;

            objCirculo.CalcularGeometria(ref perimetro, ref area, ref volumen);

            Console.WriteLine($"Perímetro del círculo: {perimetro}");
            Console.WriteLine($"Área del círculo: {area}");
            Console.WriteLine($"Volumen de la esfera: {volumen}");

     
            Console.WriteLine("\n--- Triángulo Rectángulo ---");
            Console.Write("Ingrese la longitud del cateto A del triángulo: ");
            double catetoA = Convert.ToDouble(Console.ReadLine());

            Console.Write("Ingrese la amplitud en grados del ángulo opuesto al cateto A: ");
            double anguloOpuestoA = Convert.ToDouble(Console.ReadLine());

            TrianguloRectangulo objTriangulo = new TrianguloRectangulo(catetoA, anguloOpuestoA);

            Console.WriteLine($"\nCateto A: {objTriangulo.ObtenerCatetoA():F3} metros");
            Console.WriteLine($"Cateto B: {objTriangulo.ObtenerCatetoB():F3} metros");
            Console.WriteLine($"Hipotenusa: {objTriangulo.ObtenerHipotenusa():F3} metros");
            Console.WriteLine($"Ángulo Opuesto A: {objTriangulo.ObtenerAnguloOpuestoA():F3} grados");
            Console.WriteLine($"Ángulo Opuesto B: {objTriangulo.ObtenerAnguloOpuestoB():F3} grados");
            Console.WriteLine($"Área del triángulo: {objTriangulo.ObtenerArea():F3} metros cuadrados");

            Console.ReadLine(); 
        }
    }
}
