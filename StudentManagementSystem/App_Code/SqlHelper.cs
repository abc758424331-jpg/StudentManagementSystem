using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// 数据库通用操作类
/// </summary>
public class SqlHelper
{
    // 从 Web.config 读取连接字符串
    private static readonly string ConnStr = ConfigurationManager.ConnectionStrings["SqlConn"].ConnectionString;

    // 1. 执行增、删、改 (返回受影响行数)
    public static int ExecuteNonQuery(string sql, params SqlParameter[] parameters)
    {
        using (SqlConnection conn = new SqlConnection(ConnStr))
        {
            conn.Open();
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                if (parameters != null) cmd.Parameters.AddRange(parameters);
                return cmd.ExecuteNonQuery();
            }
        }
    }

    // 2. 执行查询 (返回 DataTable 表格数据)
    public static DataTable ExecuteQuery(string sql, params SqlParameter[] parameters)
    {
        using (SqlConnection conn = new SqlConnection(ConnStr))
        {
            conn.Open();
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                if (parameters != null) cmd.Parameters.AddRange(parameters);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }
    }

    // 3. 执行查询 (只返回一个值，比如查询总数或检查登录)
    public static object ExecuteScalar(string sql, params SqlParameter[] parameters)
    {
        using (SqlConnection conn = new SqlConnection(ConnStr))
        {
            conn.Open();
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                if (parameters != null) cmd.Parameters.AddRange(parameters);
                return cmd.ExecuteScalar();
            }
        }
    }
}