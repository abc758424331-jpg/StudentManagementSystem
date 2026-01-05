using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

// 抑制 IDE 命名警告
#pragma warning disable IDE1006

public partial class CourseConfig : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. 身份验证
        if (Session["Role"] == null || Session["Role"].ToString() != "Teacher")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            if (Request.QueryString["cid"] != null)
            {
                LoadConfig(Request.QueryString["cid"]);
            }
            else
            {
                Response.Redirect("TeacherHome.aspx");
            }
        }
    }

    // --- 1. 加载当前配置 ---
    private void LoadConfig(string cid)
    {
        string tid = Session["UserId"].ToString();

        // 逻辑自查：必须确保是当前登录教师的课程
        string sql = "SELECT * FROM Courses WHERE CourseId = @cid AND TeacherId = @tid";

        DataTable dt = SqlHelper.ExecuteQuery(sql,
            new SqlParameter("@cid", cid),
            new SqlParameter("@tid", tid));

        if (dt.Rows.Count > 0)
        {
            DataRow dr = dt.Rows[0];
            lblCourseName.Text = dr["CourseName"].ToString();

            // 读取现有权重 (数据库字段假设为 RatioRegular, RatioFinal)
            // 如果数据库没有这些字段，请确保字段名一致，或者在这里做适配
            // 假设默认各 50%
            object regObj = dr["RatioRegular"];
            object finObj = dr["RatioFinal"];

            txtRegular.Text = (regObj != DBNull.Value) ? regObj.ToString() : "50";
            txtFinal.Text = (finObj != DBNull.Value) ? finObj.ToString() : "50";
        }
        else
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('❌ 无法加载配置：课程不存在或您无权管理。');window.location='TeacherHome.aspx';", true);
        }
    }

    // --- 2. 保存配置 ---
    protected void btnSave_Click(object sender, EventArgs e)
    {
        string cid = Request.QueryString["cid"];
        string tid = Session["UserId"].ToString();

        string regStr = txtRegular.Text.Trim();
        string finStr = txtFinal.Text.Trim();

        int reg, fin;

        // A. 格式验证
        if (!int.TryParse(regStr, out reg) || !int.TryParse(finStr, out fin))
        {
            ShowAlert("❌ 输入错误：权重必须是整数。");
            return;
        }

        // B. 范围验证
        if (reg < 0 || reg > 100 || fin < 0 || fin > 100)
        {
            ShowAlert("❌ 数值错误：权重必须在 0-100 之间。");
            return;
        }

        // C. 总和验证 (逻辑自查重点)
        if ((reg + fin) != 100)
        {
            ShowAlert("⚠️ 逻辑错误：平时成绩 + 期末成绩之和必须等于 100！");
            return;
        }

        // D. 执行更新
        string sql = "UPDATE Courses SET RatioRegular = @reg, RatioFinal = @fin WHERE CourseId = @cid AND TeacherId = @tid";

        try
        {
            int rows = SqlHelper.ExecuteNonQuery(sql,
                new SqlParameter("@reg", reg),
                new SqlParameter("@fin", fin),
                new SqlParameter("@cid", cid),
                new SqlParameter("@tid", tid));

            if (rows > 0)
            {
                ShowAlert("✅ 权重设置已保存！系统将按新规则自动计算总评成绩。");
            }
            else
            {
                ShowAlert("❌ 保存失败：未找到课程记录。");
            }
        }
        catch (Exception ex)
        {
            string err = ex.Message.Replace("'", "");
            ShowAlert(string.Format("❌ 数据库错误：{0}", err));
        }
    }

    // --- 辅助：统一弹窗 ---
    private void ShowAlert(string msg)
    {
        string js = string.Format("alert('{0}');", msg);
        ScriptManager.RegisterStartupScript(this, GetType(), "alert", js, true);
    }

    // --- 返回 ---
    protected void btnBack_Click(object sender, EventArgs e)
    {
        Response.Redirect("TeacherHome.aspx");
    }

    // --- 退出 ---
    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        Response.Redirect("Login.aspx");
    }
}