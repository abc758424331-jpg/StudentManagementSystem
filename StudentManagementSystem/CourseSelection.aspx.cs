using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

// 抑制 IDE1006 命名规则警告
#pragma warning disable IDE1006

public partial class CourseSelection : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. 权限验证
        if (Session["Role"] == null || Session["Role"].ToString() != "Student")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            // 显示当前用户信息
            lblUser.Text = Session["User"] != null ? Session["User"].ToString() : "Student";
            BindData();
        }
    }

    // --- 加载课程列表 ---
    private void BindData()
    {
        if (Session["UserId"] == null) return;
        int stuId = Convert.ToInt32(Session["UserId"]);

        // 查询逻辑：
        // 1. IsSelected: 判断当前学生是否已选这门课 (用于前端显示 选课/退选 按钮)
        // 2. CurrentCount: 统计当前已选人数 (用于判断是否满员)
        // 3. Status=1: 只显示已发布(通过审核)的课程
        string sql = @"
            SELECT 
                c.CourseId, 
                c.CourseName, 
                c.Credit, 
                c.MaxCapacity,
                c.Semester,
                (t.Name + ' (' + t.WorkNo + ')') as TeacherInfo,
                CASE WHEN s.ScoreId IS NOT NULL THEN 1 ELSE 0 END as IsSelected,
                (SELECT COUNT(1) FROM Scores WHERE CourseId = c.CourseId) as CurrentCount
            FROM Courses c
            LEFT JOIN Teachers t ON c.TeacherId = t.TeacherId
            LEFT JOIN Scores s ON c.CourseId = s.CourseId AND s.StudentId = @uid
            WHERE c.Status = 1
            ORDER BY c.CourseId DESC";

        DataTable dt = SqlHelper.ExecuteQuery(sql, new SqlParameter("@uid", stuId));
        gvCourses.DataSource = dt;
        gvCourses.DataBind();
    }

    // --- 行命令处理 (选课/退选) ---
    protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (Session["UserId"] == null) return;
        int stuId = Convert.ToInt32(Session["UserId"]);
        int courseId = Convert.ToInt32(e.CommandArgument);

        if (e.CommandName == "SelectCourse")
        {
            // 1. 检查是否已满员
            // (虽然前端可能根据人数变灰，但后端必须二次校验并发情况)
            string sqlCheck = "SELECT MaxCapacity, (SELECT COUNT(*) FROM Scores WHERE CourseId=@cid) as Used FROM Courses WHERE CourseId=@cid";
            DataTable dt = SqlHelper.ExecuteQuery(sqlCheck, new SqlParameter("@cid", courseId));

            if (dt.Rows.Count > 0)
            {
                int max = Convert.ToInt32(dt.Rows[0]["MaxCapacity"]);
                int used = Convert.ToInt32(dt.Rows[0]["Used"]);

                if (used >= max)
                {
                    System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('⚠️ Course is Full!');", true);
                    return;
                }
            }

            // 2. 执行选课 (插入 Scores 表，同步课程的 Semester)
            string sqlInsert = @"
                INSERT INTO Scores (StudentId, CourseId, Term)
                SELECT @sid, @cid, Semester FROM Courses WHERE CourseId=@cid";

            try
            {
                SqlHelper.ExecuteNonQuery(sqlInsert, new SqlParameter("@sid", stuId), new SqlParameter("@cid", courseId));

                // 成功提示
                System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('✅ Enrolled successfully!');", true);
            }
            catch (Exception ex)
            {
                string msg = ex.Message.Replace("'", "");
                string js = string.Format("alert('❌ Enrollment Failed: {0}');", msg);
                System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "alert", js, true);
            }
        }
        else if (e.CommandName == "DropCourse")
        {
            // 1. 检查是否已有成绩
            // 如果老师已经打分 (Score > 0 或其他标识)，则不允许退课
            string sqlCheckScore = "SELECT Score FROM Scores WHERE StudentId=@sid AND CourseId=@cid";
            object result = SqlHelper.ExecuteScalar(sqlCheckScore, new SqlParameter("@sid", stuId), new SqlParameter("@cid", courseId));

            double currentScore = 0;
            if (result != null && result != DBNull.Value)
            {
                double.TryParse(result.ToString(), out currentScore);
            }

            // 如果分数大于0，说明老师已经打分，禁止操作
            if (currentScore > 0)
            {
                string jsAlert = "alert('⛔ ACCESS DENIED: Cannot drop this course because grades have already been recorded.');";
                System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "alert", jsAlert, true);
                return; // 直接结束，不执行删除
            }

            // 只有没分数的课，才允许删除
            string sqlDelete = "DELETE FROM Scores WHERE StudentId=@sid AND CourseId=@cid";

            try
            {
                SqlHelper.ExecuteNonQuery(sqlDelete, new SqlParameter("@sid", stuId), new SqlParameter("@cid", courseId));

                // 提示成功
                System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('✅ Course dropped successfully.');", true);
            }
            catch (Exception ex)
            {
                string msg = ex.Message.Replace("'", "");
                string js = string.Format("alert('Error: {0}');", msg);
                System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "alert", js, true);
            }
        }

        // 操作完成后刷新列表状态
        BindData();
    }

    // --- 注销 ---
    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        Response.Redirect("Login.aspx");
    }
}