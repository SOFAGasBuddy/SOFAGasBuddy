using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SOFAGasBuddy.Services
{
    class LogMe
    {
        private static string log_file = "SGB.log";

        public async void write(string text)
        {
            DateTime now = DateTime.Now;
            // Write the file content to the app data directory  
            string targetFile = System.IO.Path.Combine(FileSystem.Current.AppDataDirectory, log_file);
            using FileStream outputStream = System.IO.File.OpenWrite(targetFile);
            using StreamWriter streamWriter = new StreamWriter(outputStream);
            await streamWriter.WriteAsync($"{now}: {text}");
        }
    }
}
