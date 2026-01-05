using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Drawing; // 用于 Color

// 抑制 IDE1006 命名规则警告
#pragma warning disable IDE1006

public partial class CourseApply : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. 权限验证
        if (Session["Role"] == null || Session["Role"].ToString() != "Teacher")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            // 防止 Session 为空导致报错
            lblName.Text = Session["User"] != null ? Session["User"].ToString() : "Teacher";

            // 设置默认学期，方便录入 (可根据实际情况修改或置空)
            txtTerm.Text = "2025-2026-1";
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        string cname = txtName.Text.Trim();
        string creditStr = txtCredit.Text.Trim();
        string capStr = txtCapacity.Text.Trim();
        string term = txtTerm.Text.Trim();

        // 1. 获取 TeacherId
        if (Session["UserId"] == null)
        {
            ShowMsg("❌ Session Expired. Please login again.", false);
            return;
        }
        int tid = Convert.ToInt32(Session["UserId"]);

        // 2. 基础非空验证
        if (string.IsNullOrEmpty(cname) || string.IsNullOrEmpty(creditStr) || string.IsNullOrEmpty(capStr))
        {
            ShowMsg("⚠️ Course Name, Credit, and Capacity are required.", false);
            return;
        }

        // 3. 数字格式验证
        int credit, cap;
        if (!int.TryParse(creditStr, out credit) || credit <= 0)
        {
            ShowMsg("⚠️ Credit must be a positive integer.", false);
            return;
        }
        if (!int.TryParse(capStr, out cap) || cap <= 0)
        {
            ShowMsg("⚠️ Capacity must be a positive integer.", false);
            return;
        }

        // 4. 插入数据库 (Status 默认为 0: 待审核)
        // 注意：Courses 表结构应包含 Status 字段
        string sql = @"
            INSERT INTO Courses (CourseName, TeacherId, Credit, Semester, MaxCapacity, Status) 
            VALUES (@name, @tid, @credit, @term, @cap, 0)";

        try
        {
            int rows = SqlHelper.ExecuteNonQuery(sql,
                new SqlParameter("@name", cname),
                new SqlParameter("@tid", tid),
                new SqlParameter("@credit", credit),
                new SqlParameter("@term", term),
                new SqlParameter("@cap", cap));

            if (rows > 0)
            {
                ShowMsg("✅ Application Submitted! Check status in 'Application Status'.", true);

                // 成功后清空输入框
                txtName.Text = "";
                txtCredit.Text = "";
                txtCapacity.Text = "";
            }
            else
            {
                ShowMsg("⚠️ Failed to insert record.", false);
            }
        }
        catch (Exception ex)
        {
            // 错误处理：使用 string.Format 兼容 C# 5.0
            string err = ex.Message.Replace("'", "").Replace("\r", "").Replace("\n", "");
            string jsAlert = string.Format("alert('❌ Database Error: {0}');", err);

            ScriptManager.RegisterStartupScript(this, GetType(), "alert", jsAlert, true);
            ShowMsg("❌ Error: " + ex.Message, false);
        }
    }

    // 辅助方法：统一显示提示信息
    private void ShowMsg(string msg, bool isSuccess)
    {
        lblMsg.Text = msg;
        lblMsg.ForeColor = isSuccess ? Color.LimeGreen : Color.Red;
    }

    // 注销方法
    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        Response.Redirect("Login.aspx");
    }
}