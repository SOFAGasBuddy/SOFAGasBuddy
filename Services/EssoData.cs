﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net.Http;
using System.Collections.Generic;
using HtmlAgilityPack;
using SOFAGasBuddy.Services;
using Microsoft.Maui.Controls;

namespace SOFAGasBuddy.Services
{
    class EssoData
    {
        private readonly string ID_FIELD = "_ctl0:ContentPlaceHolder1:ucAuthenticate:tbxSponsorID";
        private readonly string ID_TYPE_FIELD = "_ctl0:ContentPlaceHolder1:ucAuthenticate:ddlSponsorType";
        private readonly string VRN_FIELD = "_ctl0:ContentPlaceHolder1:ucAuthenticate:tbxVRN";
        private readonly string SUBMIT_ID = "_ctl0:ContentPlaceHolder1:ucAuthenticate:btnLogIn";
        private readonly string BALANCE_ID = "_ctl0_ContentPlaceHolder1_ucESSOPanel_lblAccountBalance";
        //private readonly string VEHICLE_ID = "_ctl0_ContentPlaceHolder1_ucESSOPanel_dgridVehicleList__ctl5_lnkbtnDetails";
        private readonly string VEHICLE_TABLE_ID = "_ctl0_ContentPlaceHolder1_ucESSOPanel_dgridVehicleList";
        //private readonly string VEHICLE_STATUS = "_ctl0_ContentPlaceHolder1_ucESSOPanel_dgridVehicleList__ctl2_lblVRNStat";
        private readonly string URL = "https://odin.aafes.com/esso/";

        public async Task<(string balance, List<SOFAGasBuddy.Services.Car>, bool success)> RefreshData(string ssn, string vrn)
        {

            HttpClient client = new();

            HtmlWeb web = new();
            HtmlDocument doc = web.Load(URL);

            var form = doc.DocumentNode.SelectSingleNode("//form[@id='aspnetForm']");

            string event_target = form.SelectSingleNode(".//input[@name='__EVENTTARGET']").GetAttributeValue("value", "");
            string event_argument = form.SelectSingleNode(".//input[@name='__EVENTARGUMENT']").GetAttributeValue("value", "");
            string view_state = form.SelectSingleNode(".//input[@name='__VIEWSTATE']").GetAttributeValue("value", "");
            string view_state_gen = form.SelectSingleNode(".//input[@name='__VIEWSTATEGENERATOR']").GetAttributeValue("value", "");
            string event_validation = form.SelectSingleNode(".//input[@name='__EVENTVALIDATION']").GetAttributeValue("value", "");

            var content = new FormUrlEncodedContent(new[]
            {
                new KeyValuePair<string, string>("__EVENTTARGET", event_target),
                new KeyValuePair<string, string>("__EVENTARGUMENT", event_argument),
                new KeyValuePair<string, string>("__VIEWSTATE", view_state),
                new KeyValuePair<string, string>("__VIEWSTATEGENERATOR",view_state_gen),
                new KeyValuePair<string, string>("__EVENTVALIDATION",event_validation),
                new KeyValuePair<string, string>(ID_FIELD,ssn),
                new KeyValuePair<string, string>(ID_TYPE_FIELD,"S"),
                new KeyValuePair<string, string>(VRN_FIELD,vrn),
                new KeyValuePair<string, string>(SUBMIT_ID,"Log In")

              });
            try
            {
                var response = await client.PostAsync(URL, content);
                string responseContent = string.Empty;

                List<Car> cars = new();

                bool first = true;
                bool success = false;
                if (response.IsSuccessStatusCode)
                {
                    responseContent = await response.Content.ReadAsStringAsync();
                    success = true; 
                }
                else
                {
                    return ("Error", cars, success);
                }

                HtmlDocument returned_data = new HtmlDocument();
                returned_data.LoadHtml(responseContent);
                var balance = returned_data.GetElementbyId(BALANCE_ID).InnerHtml;
                var vehicles = returned_data.GetElementbyId(VEHICLE_TABLE_ID);

                foreach (HtmlNode row in vehicles.SelectNodes("tr"))
                {
                    if (first)
                    {
                        first = false;
                        continue;
                    }
                    Car tmpcar = new Car();
                    HtmlNodeCollection columns = row.SelectNodes("td");

                    tmpcar.vrn = columns[0].InnerText.Trim();
                    tmpcar.type = columns[1].InnerText.Trim();
                    tmpcar.status = columns[2].InnerText.Trim();
                    tmpcar.ration = columns[3].InnerText.Trim();
                    tmpcar.ration_remaining = columns[4].InnerText.Trim();
                    tmpcar.exp_date = columns[5].InnerText.Trim();

                    cars.Add(tmpcar);

                }
                return (balance, cars, success);
            }
            catch (Exception ex)
            {
                throw new Exception($"Shit balls!: {ex.ToString()}");
            }
        }
    }
}
