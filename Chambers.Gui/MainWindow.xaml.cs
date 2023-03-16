using Microsoft.Data.SqlClient;
using Microsoft.SqlServer.Management.Common;
using Microsoft.SqlServer.Management.Smo;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Table = Microsoft.SqlServer.Management.Smo.Table;


namespace Chambers.Gui
{
    //https://www.mssqltips.com/sqlservertip/1833/generate-scripts-for-database-objects-with-smo-for-sql-server/
    //https://codeomelet.com/posts/generate-sql-script-using-beloved-csharp
    public partial class MainWindow : Window
    {
        public MainWindow() {
            InitializeComponent();
        }

        private void Button_Click(object sender, RoutedEventArgs e) {
            Server myServer = new Server(@"ASUS-STRANGE");
            //Using windows authentication
            myServer.ConnectionContext.LoginSecure = true;
            myServer.ConnectionContext.Connect();
            var databases = myServer.Databases;
            Scripter scripter = new Scripter(myServer);

            Database chambers = myServer.Databases["ELChambers"];
            /* With ScriptingOptions you can specify different scripting  
            * options, for example to include IF NOT EXISTS, DROP  
            * statements, output location etc*/
            var scriptOptions = new ScriptingOptions();
            scriptOptions.ScriptDrops = true;
            scriptOptions.IncludeIfNotExists = true;
            foreach (Table myTable in chambers.Tables) {
                /* Generating IF EXISTS and DROP command for tables */
                StringCollection tableScripts = myTable.Script(scriptOptions);
                foreach (string script in tableScripts)
                    Console.WriteLine(script);

                /* Generating CREATE TABLE command */
                tableScripts = myTable.Script();
                foreach (string script in tableScripts)
                    Console.WriteLine(script);
            }

            if (myServer.ConnectionContext.IsOpen)
            {

                myServer.ConnectionContext.Disconnect();
            }

            //var fileName = @"C:\csharp-sql-script-generator\backup.sql";
            //var connectionString = @"Data Source=ASUS-STRANGE; Database=ELChambers; Integrated Security=true;";
            //var databaseName = "ELChambers";
            //var schemaName = "dbo";

            //var server = new Smo().Server(new ServerConnection(new SqlConnection(connectionString)));
            //var options = new Smo.ScriptingOptions();
            //var databases = server.Databases[databaseName];

            //options.FileName = fileName;
            //options.EnforceScriptingOptions = true;
            //options.WithDependencies = true;
            //options.IncludeHeaders = true;
            //options.ScriptDrops = false;
            //options.AppendToFile = true;
            //options.ScriptSchema = true;
            //options.ScriptData = true;
            //options.Indexes = true;
        }
    }
}
