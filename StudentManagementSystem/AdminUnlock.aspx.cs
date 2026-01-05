using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

// 抑制 IDE 命名警告
#pragma warning disable IDE1006

public partial class AdminUnlock : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. 权限验证 (仅限管理员)
        if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            BindData();
        }
    }

    // --- 1. 加载锁定课程列表 ---
    private void BindData(string searchKey = "")
    {
        // 查询逻辑：
        // 1. 筛选 Status = 2 (已归档/已锁定) 的课程
        // 2. 支持模糊搜索 (课程名 或 教师名)
        string sql = @"
            SELECT 
                c.CourseId, 
                c.CourseName, 
                c.Semester,
                c.Status,
                t.Name AS TeacherName, 
                t.WorkNo,
                (SELECT COUNT(*) FROM Scores WHERE CourseId = c.CourseId) AS StudentCount
            FROM Courses c
            JOIN Teachers t ON c.TeacherId = t.TeacherId
            WHERE c.Status = 2 ";

        if (!string.IsNullOrEmpty(searchKey))
        {
            sql += " AND (c.CourseName LIKE @key OR t.Name LIKE @key)";
        }

        sql += " ORDER BY c.Semester DESC, c.CourseId DESC";

        SqlParameter[] p = null;
        if (!string.IsNullOrEmpty(searchKey))
        {
            p = new SqlParameter[] { new SqlParameter("@key", "%" + searchKey + "%") };
        }

        DataTable dt = SqlHelper.ExecuteQuery(sql, p);
        gvLockedCourses.DataSource = dt;
        gvLockedCourses.DataBind();
    }

    // --- 2. 搜索按钮 ---
    protected void btnSearch_Click(object sender, EventArgs e)
    {
        string key = txtSearch.Text.Trim();
        BindData(key);
    }

    // --- 3. 解锁操作 ---
    protected void gvLockedCourses_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Unlock")
        {
            int courseId = Convert.ToInt32(e.CommandArgument);

            // 逻辑自查：
            // 将状态从 2 (已锁定) 重置为 1 (进行中/已发布)
            // 增加 AND Status=2 条件，防止重复解锁或状态不一致
            string sql = "UPDATE Courses SET Status = 1 WHERE CourseId = @id AND Status = 2";

            try
            {
                int rows = SqlHelper.ExecuteNonQuery(sql, new SqlParameter("@id", courseId));

                if (rows > 0)
                {
                    // 使用 string.Format 兼容性写法
                    string js = string.Format("alert('✅ 课程已解锁！\\n教师现在可以重新录入该课程的成绩。');");
                    ScriptManager.RegisterStartupScript(this, GetType(), "toast", js, true);
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('⚠️ 操作无效：该课程可能已被解锁或状态异常。');", true);
                }
            }
            catch (Exception ex)
            {
                string err = ex.Message.Replace("'", "");
                string jsError = string.Format("alert('❌ 系统错误：{0}');", err);
                ScriptManager.RegisterStartupScript(this, GetType(), "error", jsError, true);
            }

            // 操作后刷新列表，保持搜索关键词
            BindData(txtSearch.Text.Trim());
        }
    }

    // --- 退出登录 ---
    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        Response.Redirect("Login.aspx");
    }
}