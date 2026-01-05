using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

// 抑制 IDE1006 命名规则警告
#pragma warning disable IDE1006

public partial class Login : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // 每次进入登录页，彻底清除会话，确保安全退出
            Session.Clear();
            Session.Abandon();
        }
    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        // 1. 获取输入 (去除首尾空格)
        string user = txtUser.Text.Trim();
        string pwd = txtPwd.Text.Trim();
        string role = "";

        // 2. 判定身份 (检查前端 RadioButton 的选中状态)
        if (rbStudent.Checked) role = "Student";
        else if (rbTeacher.Checked) role = "Teacher";
        else if (rbAdmin.Checked) role = "Admin";

        // 3. 基础非空校验
        if (string.IsNullOrEmpty(user) || string.IsNullOrEmpty(pwd))
        {
            lblMsg.Text = "⚠️ 请输入账号和密码";
            return;
        }

        try
        {
            string sql = "";

            // 4. 根据角色构建 SQL
            if (role == "Student")
            {
                // 学生：使用学号 (StuNumber) 登录
                sql = "SELECT * FROM Students WHERE StuNumber=@u AND Password=@p";
            }
            else if (role == "Teacher")
            {
                // 教师：使用工号 (WorkNo) 登录
                sql = "SELECT * FROM Teachers WHERE WorkNo=@u AND Password=@p";
            }
            else if (role == "Admin")
            {
                // 管理员：查询 Admins 表 (如果没有该表，下方 catch 会捕获)
                sql = "SELECT * FROM Admins WHERE Username=@u AND Password=@p";
            }

            // 执行查询
            DataTable dt = SqlHelper.ExecuteQuery(sql, new SqlParameter("@u", user), new SqlParameter("@p", pwd));

            if (dt.Rows.Count > 0)
            {
                DataRow dr = dt.Rows[0];

                // 登录成功，写入 Session
                Session["Role"] = role;

                if (role == "Student")
                {
                    Session["User"] = dr["Name"].ToString();
                    Session["UserId"] = dr["StudentId"].ToString();
                    Session["UserNumber"] = dr["StuNumber"].ToString(); // 记录学号备用
                    Response.Redirect("StudentHome.aspx");
                }
                else if (role == "Teacher")
                {
                    Session["User"] = dr["Name"].ToString();
                    Session["UserId"] = dr["TeacherId"].ToString();
                    Response.Redirect("TeacherHome.aspx");
                }
                else // Admin
                {
                    Session["User"] = "管理员";
                    Session["UserId"] = "1";
                    Response.Redirect("Default.aspx");
                }
            }
            else
            {
                // 登录失败
                lblMsg.Text = "❌ 登录失败：账号或密码错误";
            }
        }
        catch (Exception ex)
        {
            // 错误处理：如果数据库中缺少 Admins 表，给予明确提示
            if (role == "Admin" && ex.Message.Contains("Admins"))
            {
                lblMsg.Text = "❌ 配置错误：数据库中缺少 'Admins' 表，请联系管理员。";
            }
            else
            {
                lblMsg.Text = "❌ 系统错误：" + ex.Message;
            }
        }
    }
}