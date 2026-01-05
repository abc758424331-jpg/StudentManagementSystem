using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

// 抑制命名警告
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
            // 显示当前用户信息 (备用)
            lblUser.Text = Session["User"] != null ? Session["User"].ToString() : "同学";
            BindData();
        }
    }

    // --- 1. 加载课程列表 ---
    private void BindData()
    {
        if (Session["UserId"] == null) return;
        int stuId = Convert.ToInt32(Session["UserId"]);

        // 查询逻辑：
        // 1. IsSelected: 判断当前学生是否已选这门课
        // 2. CurrentCount: 统计当前已选人数
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
            ORDER BY c.Semester DESC, c.CourseId DESC";

        DataTable dt = SqlHelper.ExecuteQuery(sql, new SqlParameter("@uid", stuId));
        gvCourses.DataSource = dt;
        gvCourses.DataBind();
    }

    // --- 2. 行命令处理 (选课/退选) ---
    protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (Session["UserId"] == null) return;
        int stuId = Convert.ToInt32(Session["UserId"]);
        int courseId = Convert.ToInt32(e.CommandArgument);

        if (e.CommandName == "SelectCourse")
        {
            // --- 选课逻辑 ---

            // A. 二次检查是否已满员 (防止并发超员)
            string sqlCheck = "SELECT MaxCapacity, (SELECT COUNT(*) FROM Scores WHERE CourseId=@cid) as Used FROM Courses WHERE CourseId=@cid";
            DataTable dt = SqlHelper.ExecuteQuery(sqlCheck, new SqlParameter("@cid", courseId));

            if (dt.Rows.Count > 0)
            {
                int max = Convert.ToInt32(dt.Rows[0]["MaxCapacity"]);
                int used = Convert.ToInt32(dt.Rows[0]["Used"]);

                if (used >= max)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('⚠️ 选课失败：手慢了，该课程已满员！');", true);
                    return;
                }
            }

            // B. 执行选课 (插入 Scores 表，同步课程的 Semester)
            string sqlInsert = @"
                INSERT INTO Scores (StudentId, CourseId, Term)
                SELECT @sid, @cid, Semester FROM Courses WHERE CourseId=@cid";

            try
            {
                SqlHelper.ExecuteNonQuery(sqlInsert, new SqlParameter("@sid", stuId), new SqlParameter("@cid", courseId));

                // 成功提示
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('✅ 选课成功！');", true);
            }
            catch (Exception ex)
            {
                string msg = ex.Message.Replace("'", "");
                // 检查是否重复选课 (虽然前端按钮已控制，但后端需兜底)
                if (msg.Contains("PRIMARY") || msg.Contains("UNIQUE"))
                    msg = "您已选修过该课程，不可重复选择。";

                string js = string.Format("alert('❌ 选课失败：{0}');", msg);
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", js, true);
            }
        }
        else if (e.CommandName == "DropCourse")
        {
            // --- 退课逻辑 ---

            // A. 检查是否已有成绩
            // 如果老师已经打分 (Score >= 0 或其他标识)，则不允许退课
            // 注意：部分系统 Score 默认为 NULL 或 -1，具体视数据库设计。这里假设 >0 代表已出分。
            // 更严谨的做法是检查 Score 是否为 NULL。
            string sqlCheckScore = "SELECT Score FROM Scores WHERE StudentId=@sid AND CourseId=@cid";
            object result = SqlHelper.ExecuteScalar(sqlCheckScore, new SqlParameter("@sid", stuId), new SqlParameter("@cid", courseId));

            if (result != null && result != DBNull.Value)
            {
                // 如果能查到分数 (即便是0分也算有了记录)，禁止退课
                string jsAlert = "alert('⛔ 操作拒绝：该课程已录入成绩，无法退课。');";
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", jsAlert, true);
                return;
            }

            // B. 执行删除
            string sqlDelete = "DELETE FROM Scores WHERE StudentId=@sid AND CourseId=@cid";

            try
            {
                SqlHelper.ExecuteNonQuery(sqlDelete, new SqlParameter("@sid", stuId), new SqlParameter("@cid", courseId));

                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('✅ 退课成功。');", true);
            }
            catch (Exception ex)
            {
                string msg = ex.Message.Replace("'", "");
                string js = string.Format("alert('❌ 系统错误：{0}');", msg);
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", js, true);
            }
        }

        // C. 操作完成后刷新列表状态
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