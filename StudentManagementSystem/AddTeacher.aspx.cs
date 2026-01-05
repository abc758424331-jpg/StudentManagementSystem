using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Drawing;

// 抑制 IDE1006 命名规则警告
#pragma warning disable IDE1006

public partial class AddTeacher : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. 权限验证
        if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            // 2. 显示当前管理员名称
            // 使用 FindControl 避免编译时因找不到控件 ID 而报错
            Label lbl = this.FindControl("lblUser") as Label;
            if (lbl != null && Session["User"] != null)
            {
                lbl.Text = Session["User"].ToString();
            }
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        string no = txtWorkNo.Text.Trim();
        string name = txtName.Text.Trim();
        string phone = txtPhone.Text.Trim();

        // 基础验证
        if (string.IsNullOrEmpty(no) || string.IsNullOrEmpty(name))
        {
            lblMsg.Text = "⚠️ ID and Name are required.";
            lblMsg.ForeColor = Color.Red;
            return;
        }

        // 默认密码 123456
        string sql = "INSERT INTO Teachers (WorkNo, Name, Phone, Password) VALUES (@no, @na, @ph, '123456')";

        try
        {
            SqlHelper.ExecuteNonQuery(sql,
                new SqlParameter("@no", no),
                new SqlParameter("@na", name),
                new SqlParameter("@ph", phone));

            // 成功提示
            lblMsg.Text = "✅ Faculty Registered! Default Pwd: 123456";
            lblMsg.ForeColor = Color.LimeGreen;

            // 清空并聚焦
            txtWorkNo.Text = "";
            txtName.Text = "";
            txtPhone.Text = "";
            txtWorkNo.Focus();
        }
        catch (Exception ex)
        {
            // 错误处理
            if (ex.Message.Contains("PRIMARY KEY") || ex.Message.Contains("UNIQUE"))
            {
                lblMsg.Text = "❌ Error: Employee ID already exists.";
            }
            else
            {
                lblMsg.Text = "❌ System Error: " + ex.Message;
            }
            lblMsg.ForeColor = Color.Red;
        }
    }

    // [新增] 修复报错：添加前端调用的注销方法
    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        Response.Redirect("Login.aspx");
    }
}