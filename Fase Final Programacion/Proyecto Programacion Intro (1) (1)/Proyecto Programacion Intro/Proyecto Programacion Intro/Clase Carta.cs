using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Proyecto_Programacion_Intro
{
    public class Carta
    {
        public string Nombre { get; private set; }
        public int Nivel { get; private set; }
        public double Daño { get; private set; }
        public double Vida { get; private set; }
        public double Dps { get; private set; }
        public double Elixir { get; private set; }

        public Carta(string nombre, int nivel, double daño, double vida, double dps, double elixir)
        {
            Nombre = nombre;
            Nivel = nivel;
            Daño = daño;
            Vida = vida;
            Dps = dps;
            Elixir = elixir;
        }
    }
}
