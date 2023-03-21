using Microsoft.SqlServer.Management.Common;
using Microsoft.SqlServer.Management.Smo;
using System;
using System.Collections.Specialized;
using System.IO;
using System.Text;
using System.Windows;
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
            GenerateSqlScripts("ELChambers");
        }


        public void GenerateSqlScripts(string dbName) {

            //get the full location of the assembly with DaoTests in it
            string? assemblyName = System.Reflection.Assembly.GetAssembly(this.GetType())?.Location;
            var assmFile = new FileInfo(assemblyName!);
            var fileInfo = new FileInfo(assmFile.Directory + @"\Chambers.sql");


            StringBuilder sb = new ();
            Server myServer = new (@"ASUS-STRANGE");
            //Using windows authentication
            myServer.ConnectionContext.LoginSecure = true;
            myServer.ConnectionContext.Connect();
            Database db = myServer.Databases[dbName];

            var scriptOpt = new ScriptingOptions();
            scriptOpt.TargetServerVersion = SqlServerVersion.Version105; // Windows 2008 R2
            scriptOpt.AnsiPadding = true;
            scriptOpt.WithDependencies = true;
            scriptOpt.IncludeHeaders = true;
            scriptOpt.SchemaQualify = true;
            scriptOpt.ExtendedProperties = true;
            scriptOpt.TargetDatabaseEngineType = DatabaseEngineType.Standalone;
            scriptOpt.IncludeDatabaseContext = true;
            scriptOpt.ScriptDrops = false;
            scriptOpt.ScriptData = false;
            scriptOpt.ScriptSchema = true;
            scriptOpt.DriAllConstraints = true;
            scriptOpt.DriForeignKeys = true;
            scriptOpt.Indexes = true;
            scriptOpt.DriPrimaryKey = true;
            scriptOpt.DriUniqueKeys = true;
            scriptOpt.DriChecks = true;
            scriptOpt.AllowSystemObjects = false;
            scriptOpt.AppendToFile = false;
            scriptOpt.ScriptBatchTerminator = true;


            // script Tables
            foreach (Table t in db.Tables) {
                if (t.Schema == "dbo"/* && !t.IsSystemObject*/) {
                    StringCollection sc = t.Script(scriptOpt);
                    foreach (string? s in sc) {
                        sb.AppendLine(s);
                    }
                }

            }

            //Script Stored Procedures
            foreach (StoredProcedure sp in db.StoredProcedures) {
                if (sp.Schema == "dbo"/* && !t.IsSystemObject*/) {
                    var sc = sp.Script(scriptOpt);
                    foreach (string? s in sc) {
                        sb.AppendLine(s);
                    }
                }

            }

            //Views
            foreach (View v in db.Views) {
                if (v.Schema == "dbo"/* && !t.IsSystemObject*/) {
                    StringCollection sc = v.Script(scriptOpt);
                    foreach (string? s in sc) {
                        sb.AppendLine(s);
                    }
                }

            }

            File.WriteAllText(fileInfo!.FullName, sb.ToString());

            if (myServer.ConnectionContext.IsOpen) {
                myServer.ConnectionContext.Disconnect();
            }
        }


        //private void Button_Click(object sender, RoutedEventArgs e) {
        //    var myServer = new Server(@"ASUS-STRANGE");
        //    //Using windows authentication
        //    myServer.ConnectionContext.LoginSecure = true;
        //    myServer.ConnectionContext.Connect();
        //    var databases = myServer.Databases;
        //    Scripter scripter = new Scripter(myServer);

        //    Database chambers = myServer.Databases["ELChambers"];
        //    /* With ScriptingOptions you can specify different scripting  
        //    * options, for example to include IF NOT EXISTS, DROP  
        //    * statements, output location etc*/
        //    var scriptOptions = new ScriptingOptions();
        //    scriptOptions.ScriptDrops = true;
        //    scriptOptions.IncludeIfNotExists = true;
        //    foreach (Table myTable in chambers.Tables) {
        //        /* Generating IF EXISTS and DROP command for tables */
        //        StringCollection tableScripts = myTable.Script(scriptOptions);
        //        foreach (string? script in tableScripts)
        //        {
        //            Console.WriteLine(script);
        //        }

        //        /* Generating CREATE TABLE command */
        //        tableScripts = myTable.Script();
        //        foreach (string? script in tableScripts)
        //            Console.WriteLine(script);
        //    }

        //    if (myServer.ConnectionContext.IsOpen)
        //    {

        //        myServer.ConnectionContext.Disconnect();
        //    }

        //    //var fileName = @"C:\csharp-sql-script-generator\backup.sql";
        //    //var connectionString = @"Data Source=ASUS-STRANGE; Database=ELChambers; Integrated Security=true;";
        //    //var databaseName = "ELChambers";
        //    //var schemaName = "dbo";

        //    //var server = new Smo().Server(new ServerConnection(new SqlConnection(connectionString)));
        //    //var options = new Smo.ScriptingOptions();
        //    //var databases = server.Databases[databaseName];

        //    //options.FileName = fileName;
        //    //options.EnforceScriptingOptions = true;
        //    //options.WithDependencies = true;
        //    //options.IncludeHeaders = true;
        //    //options.ScriptDrops = false;
        //    //options.AppendToFile = true;
        //    //options.ScriptSchema = true;
        //    //options.ScriptData = true;
        //    //options.Indexes = true;
        //}

    }
}
