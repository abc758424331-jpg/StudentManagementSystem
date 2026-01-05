using System;
using System.Data.SqlClient;
using System.Drawing;
using System.Web.UI;

public partial class CourseApply : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 权限验证
        if (Session["Role"] == null || Session["Role"].ToString() != "Teacher")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            // 防止 Session 为空报错
            lblName.Text = Session["User"] != null ? Session["User"].ToString() : "Teacher";
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
            ShowMsg("⚠️ All fields are required.", false);
            return;
        }

        // 3. 数值类型验证
        decimal credit;
        int cap;
        bool b1 = decimal.TryParse(creditStr, out credit);
        bool b2 = int.TryParse(capStr, out cap);

        if (!b1 || !b2)
        {
            ShowMsg("⚠️ Credit/Capacity must be valid numbers.", false);
            return;
        }

        // =========================================================================
        // [最终修复]：移除数据库中不存在的 'Description' 和 'CourseType' 字段
        // 只插入最基础的字段，确保 100% 成功
        // =========================================================================
        string sql = @"
            INSERT INTO Courses 
            (CourseName, TeacherId, Credit, semester, MaxCapacity, status, 
             WeightRegular, WeightHomework, WeightMidterm, WeightFinal) 
            VALUES 
            (@name, @tid, @credit, @term, @cap, 0, 
             20, 20, 30, 30)";

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

                // 成功后清空
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

    private void ShowMsg(string msg, bool isSuccess)
    {
        lblMsg.Text = msg;
        lblMsg.ForeColor = isSuccess ? Color.LimeGreen : Color.Red;
    }

    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        Response.Redirect("Login.aspx");
    }
}