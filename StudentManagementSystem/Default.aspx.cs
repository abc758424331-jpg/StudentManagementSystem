using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

// 抑制 IDE1006 命名规则警告，因为 WebForms 事件处理程序必须匹配前端控件 ID
#pragma warning disable IDE1006

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. 权限验证
        if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            lblName.Text = Session["User"] != null ? Session["User"].ToString() : "Admin";
            LoadStats();
            BindStudents();
            BindTeachers();
        }
    }

    // --- 1. 加载 HUD 统计数据 ---
    private void LoadStats()
    {
        try
        {
            object stuCount = SqlHelper.ExecuteScalar("SELECT COUNT(*) FROM Students");
            ltlStudents.Text = stuCount.ToString();

            object teaCount = SqlHelper.ExecuteScalar("SELECT COUNT(*) FROM Teachers");
            ltlTeachers.Text = teaCount.ToString();

            // 统计活跃课程 (Status=1)
            object courseCount = SqlHelper.ExecuteScalar("SELECT COUNT(*) FROM Courses WHERE status=1");
            ltlCourses.Text = courseCount.ToString();
        }
        catch
        {
            // 容错处理：如果数据库未初始化，显示 0
            ltlStudents.Text = "0";
            ltlTeachers.Text = "0";
            ltlCourses.Text = "0";
        }
    }

    // --- 2. 绑定列表 ---
    private void BindStudents()
    {
        string sql = @"
            SELECT s.StudentId, s.StuNumber, s.Name, s.Gender, 
                   c.ClassName, s.Phone
            FROM Students s
            LEFT JOIN Classes c ON s.ClassId = c.ClassId
            ORDER BY s.StuNumber DESC";

        DataTable dt = SqlHelper.ExecuteQuery(sql);
        gvStudents.DataSource = dt;
        gvStudents.DataBind();
    }

    private void BindTeachers()
    {
        string sql = "SELECT * FROM Teachers ORDER BY WorkNo ASC";
        DataTable dt = SqlHelper.ExecuteQuery(sql);
        gvTeachers.DataSource = dt;
        gvTeachers.DataBind();
    }

    // --- 3. 删除逻辑 (级联删除) ---

    // 删除学生
    protected void gvStudents_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "DelStudent")
        {
            int id = Convert.ToInt32(e.CommandArgument);

            try
            {
                // 1. 删除相关的成绩记录
                SqlHelper.ExecuteNonQuery("DELETE FROM Scores WHERE StudentId=@id", new SqlParameter("@id", id));

                // 2. 删除相关的评论记录
                SqlHelper.ExecuteNonQuery("DELETE FROM CourseComments WHERE StudentId=@id", new SqlParameter("@id", id));

                // 3. 删除学生档案
                SqlHelper.ExecuteNonQuery("DELETE FROM Students WHERE StudentId=@id", new SqlParameter("@id", id));

                BindStudents();
                LoadStats();

                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('✅ Student record deleted.');", true);
            }
            catch (Exception ex)
            {
                string err = ex.Message.Replace("'", "");
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", string.Format("alert('❌ Delete Failed: {0}');", err), true);
            }
        }
    }

    // 删除教师
    protected void gvTeachers_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "DelTeacher")
        {
            int id = Convert.ToInt32(e.CommandArgument);

            try
            {
                // 1. 删除该教师课程下的所有成绩 (必须先删成绩，否则有外键约束)
                SqlHelper.ExecuteNonQuery(@"
                    DELETE FROM Scores 
                    WHERE CourseId IN (SELECT CourseId FROM Courses WHERE TeacherId=@id)",
                    new SqlParameter("@id", id));

                // 2. 删除该教师课程下的所有评论
                SqlHelper.ExecuteNonQuery(@"
                    DELETE FROM CourseComments 
                    WHERE CourseId IN (SELECT CourseId FROM Courses WHERE TeacherId=@id)",
                    new SqlParameter("@id", id));

                // 3. 删除该教师的所有课程
                SqlHelper.ExecuteNonQuery("DELETE FROM Courses WHERE TeacherId=@id", new SqlParameter("@id", id));

                // 4. 删除教师档案
                SqlHelper.ExecuteNonQuery("DELETE FROM Teachers WHERE TeacherId=@id", new SqlParameter("@id", id));

                BindTeachers();
                LoadStats();

                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('✅ Faculty profile and associated courses deleted.');", true);
            }
            catch (Exception ex)
            {
                string err = ex.Message.Replace("'", "");
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", string.Format("alert('❌ Delete Failed: {0}');", err), true);
            }
        }
    }

    // --- 4. 分页 ---
    protected void gvStudents_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvStudents.PageIndex = e.NewPageIndex;
        BindStudents();
    }

    protected void gvTeachers_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvTeachers.PageIndex = e.NewPageIndex;
        BindTeachers();
    }

    // --- 5. 注销 ---
    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        Response.Redirect("Login.aspx");
    }
}