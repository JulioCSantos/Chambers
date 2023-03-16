using ChambersDataModel.Entities;
using System;
using System.Windows;

namespace Chambers.Gui
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        public App()
        {


            var dbContext = new ChambersDbContext();
            //dbContext.SeedDb();
            Console.WriteLine("Hello, " + dbContext.Database);
        }
    }
}
