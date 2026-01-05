using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class StudentRetake : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 权限验证
        if (Session["Role"] == null || Session["Role"].ToString() != "Student")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            lblUser.Text = Session["User"] != null ? Session["User"].ToString() : "Student";
            BindData();
        }
    }

    private void BindData()
    {
        int stuId = Convert.ToInt32(Session["UserId"]);

        // 查询条件：当前学生 + 分数不及格 (<60)
        string sql = @"
            SELECT 
                s.ScoreId, 
                s.Score, 
                s.Term,
                s.RetakeStatus,
                c.CourseName,
                t.Name as TeacherName
            FROM Scores s
            JOIN Courses c ON s.CourseId = c.CourseId
            LEFT JOIN Teachers t ON c.TeacherId = t.TeacherId
            WHERE s.StudentId = @uid AND s.Score < 60
            ORDER BY s.Term DESC";

        DataTable dt = SqlHelper.ExecuteQuery(sql, new SqlParameter("@uid", stuId));
        gvRetake.DataSource = dt;
        gvRetake.DataBind();
    }

    protected void gvRetake_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Apply")
        {
            int scoreId = Convert.ToInt32(e.CommandArgument);

            // 更新状态为 2 (已申请)
            string sql = "UPDATE Scores SET RetakeStatus = 2 WHERE ScoreId = @id";

            try
            {
                SqlHelper.ExecuteNonQuery(sql, new SqlParameter("@id", scoreId));
                BindData(); // 刷新列表

                // 弹窗提示成功
                System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('✅ Application Submitted! Waiting for approval.');", true);
            }
            catch (Exception ex)
            {
                System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('❌ Error: " + ex.Message + "');", true);
            }
        }
    }

    // 辅助方法：生成状态徽章 HTML
    public string GetStatusBadge(object statusObj)
    {
        int s = Convert.ToInt32(statusObj);
        if (s == 2) return "<span class='badge bg-pending'>PENDING</span>"; // 审核中
        if (s == 3) return "<span class='badge bg-done'>APPROVED</span>";   // 已通过
        return "<span class='badge bg-fail'>FAILED</span>";                 // 挂科/需补考
    }
}