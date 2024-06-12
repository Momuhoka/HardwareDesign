using System;
using System.IO;
namespace ConsoleApp1
{
    class BinToChar
    {
        static void Main(string[] args)
        {
            //读
            BinaryReader binaryReader;
            FileStream fs = new FileStream("1.mid", FileMode.Open);
            binaryReader = new BinaryReader(fs);
            long length = fs.Length;
            byte[] bytes;
            bytes = binaryReader.ReadBytes((int)length);
            for (int i = 0; i < length; i++)
            {
                Console.Write("{0:x2} ", bytes[i]);
            }

            //写
            if (!File.Exists("midi2txt_out.txt"))
            {
                File.Create("midi2txt_out.txt");
            }
            StreamWriter streamWriter = new StreamWriter("midi2txt_outtxt", true);
            for (int i = 0; i < length; i++)
            {
                streamWriter.Write("{0:x2} ", bytes[i]);
            }
        }
    }
}