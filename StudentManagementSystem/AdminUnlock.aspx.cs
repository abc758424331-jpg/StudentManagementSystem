using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class AdminUnlock : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. 权限验证
        if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            BindData();
        }
    }

    private void BindData()
    {
        // 查询所有申请解锁 (IsLocked=2) 的记录
        // 联表查询：学生信息、教师信息、课程信息
        string sql = @"
            SELECT 
                s.ScoreId, s.Score,
                st.Name AS StuName, st.StuNumber,
                c.CourseName,
                t.Name AS TeaName
            FROM Scores s
            JOIN Students st ON s.StudentId = st.StudentId
            JOIN Courses c ON s.CourseId = c.CourseId
            JOIN Teachers t ON c.TeacherId = t.TeacherId
            WHERE s.IsLocked = 2
            ORDER BY s.ScoreId DESC";

        DataTable dt = SqlHelper.ExecuteQuery(sql);
        gvUnlock.DataSource = dt;
        gvUnlock.DataBind();
    }

    protected void GvUnlock_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int scoreId = Convert.ToInt32(e.CommandArgument);

        if (e.CommandName == "Unlock")
        {
            // 同意解锁：设为 0 (未锁定)
            string sql = "UPDATE Scores SET IsLocked = 0 WHERE ScoreId = @id";
            SqlHelper.ExecuteNonQuery(sql, new SqlParameter("@id", scoreId));

            System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('✅ Grade Unlocked. Teacher can modify it now.');", true);
        }
        else if (e.CommandName == "Reject")
        {
            // 拒绝解锁：设回 1 (已锁定)
            string sql = "UPDATE Scores SET IsLocked = 1 WHERE ScoreId = @id";
            SqlHelper.ExecuteNonQuery(sql, new SqlParameter("@id", scoreId));

            System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('🚫 Request Rejected. Grade remains locked.');", true);
        }

        // 刷新列表
        BindData();
    }
}