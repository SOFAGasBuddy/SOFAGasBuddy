using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SOFAGasBuddy.Services
{
    internal class Car
    {
        public string vrn;
        public string type;
        public string status;
        public string ration;
        public string ration_remaining;
        public string exp_date;

        public Car()
        {
            vrn = string.Empty;
            type = string.Empty;
            status = string.Empty;
            ration = string.Empty;
            ration_remaining = string.Empty;
            exp_date = string.Empty;

        }
    }

}
