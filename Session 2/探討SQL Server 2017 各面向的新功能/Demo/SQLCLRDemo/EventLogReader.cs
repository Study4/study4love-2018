using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Collections;

public partial class UserDefinedFunctions
{
    //以 Table 的型態傳回 Windows 的 Event Log

    //回傳一個實作 IEnumerable 介面的物件
    [Microsoft.SqlServer.Server.SqlFunction(FillRowMethodName = "FillRow",
        TableDefinition = "[timeWritten] DateTime,[message] nvarchar(max),[category] nvarchar(100), [instanceId] bigint")]
    public static IEnumerable InitMethod(string LogName)
    {
        return new EventLog(LogName, Environment.MachineName).Entries;
    }

    //SQL Engine 透過 IEnumerable 介面所提供的 Enumerator 逐步取出每一個物件
    //呼叫以下的方法，將物件的內容改以輸出參數傳回，組成單筆紀錄
    public static void FillRow(object obj,out SqlDateTime timeWritten,
        out SqlChars message,out SqlChars category, out SqlInt64 instanceId)
    {
        EventLogEntry logEntry = (EventLogEntry)obj;
        timeWritten = new SqlDateTime(logEntry.TimeWritten);
        message = new SqlChars(logEntry.Message);
        category = new SqlChars(logEntry.Category);
        instanceId = new SqlInt64(logEntry.InstanceId);
    }
}
