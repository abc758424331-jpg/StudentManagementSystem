using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI; // 必须引用
using System.Web.UI.WebControls;
using System.Drawing;

// 抑制 IDE1006 命名规则警告
#pragma warning disable IDE1006

public partial class AddStudent : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. 权限校验
        if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            // 2. 安全获取用户名控件 (防止编译报错)
            Label lbl = this.FindControl("lblUser") as Label;
            if (lbl != null && Session["User"] != null)
            {
                lbl.Text = Session["User"].ToString();
            }

            LoadClasses();
        }
    }

    // --- 加载班级下拉框 ---
    private void LoadClasses()
    {
        string sql = "SELECT ClassId, ClassName FROM Classes";
        DataTable dt = SqlHelper.ExecuteQuery(sql);

        ddlClass.DataSource = dt;
        ddlClass.DataTextField = "ClassName";
        ddlClass.DataValueField = "ClassId";
        ddlClass.DataBind();

        // 插入默认提示项
        ddlClass.Items.Insert(0, new ListItem("-- Select Class --", "0"));
    }

    // --- 保存学生 ---
    protected void btnSave_Click(object sender, EventArgs e)
    {
        string no = txtStuNo.Text.Trim();
        string name = txtName.Text.Trim();
        string phone = txtPhone.Text.Trim();
        string gender = ddlGender.SelectedValue;
        string classId = ddlClass.SelectedValue;

        // 基础验证
        if (string.IsNullOrEmpty(no) || string.IsNullOrEmpty(name))
        {
            lblMsg.Text = "⚠️ Student ID and Name are required.";
            lblMsg.ForeColor = Color.Red;
            return;
        }

        if (classId == "0")
        {
            lblMsg.Text = "⚠️ Please select a class.";
            lblMsg.ForeColor = Color.Red;
            return;
        }

        // 默认密码 123456
        string sql = "INSERT INTO Students (StuNumber, Name, Gender, ClassId, Phone, Password) VALUES (@no, @na, @gen, @cid, @ph, '123456')";

        try
        {
            SqlHelper.ExecuteNonQuery(sql,
                new SqlParameter("@no", no),
                new SqlParameter("@na", name),
                new SqlParameter("@gen", gender),
                new SqlParameter("@cid", classId),
                new SqlParameter("@ph", phone));

            lblMsg.Text = "✅ Student Enrolled! Default Pwd: 123456";
            lblMsg.ForeColor = Color.LimeGreen;

            // 清空并聚焦
            txtStuNo.Text = "";
            txtName.Text = "";
            txtPhone.Text = "";
            txtStuNo.Focus();
        }
        catch (Exception ex)
        {
            // 捕获主键冲突错误
            if (ex.Message.Contains("PRIMARY KEY") || ex.Message.Contains("UNIQUE"))
            {
                lblMsg.Text = "❌ Error: Student ID already exists.";
            }
            else
            {
                lblMsg.Text = "❌ Database Error: " + ex.Message;
            }
            lblMsg.ForeColor = Color.Red;
        }
    }

    // [新增] 修复报错：添加注销方法
    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        Response.Redirect("Login.aspx");
    }
}