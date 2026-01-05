using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class CourseApproval : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 权限验证
        if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            BindData();
        }
    }

    private void BindData()
    {
        // 仅查询 Status = 0 (待审核) 的课程
        string sql = @"
            SELECT c.CourseId, c.CourseName, c.Credit, c.Semester, c.MaxCapacity, 
                   t.Name as TeacherName, t.WorkNo
            FROM Courses c
            JOIN Teachers t ON c.TeacherId = t.TeacherId
            WHERE c.Status = 0
            ORDER BY c.CourseId DESC";

        DataTable dt = SqlHelper.ExecuteQuery(sql);
        gvApproval.DataSource = dt;
        gvApproval.DataBind();
    }

    protected void gvApproval_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int cid = Convert.ToInt32(e.CommandArgument);

        if (e.CommandName == "Pass")
        {
            // 通过：Status 变为 1
            string sql = "UPDATE Courses SET Status = 1 WHERE CourseId = @id";
            SqlHelper.ExecuteNonQuery(sql, new SqlParameter("@id", cid));

            // 弹窗提示
            System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('✅ Course Approved and Published!');", true);
        }
        else if (e.CommandName == "Reject")
        {
            // 拒绝：直接删除申请
            string sql = "DELETE FROM Courses WHERE CourseId = @id";
            SqlHelper.ExecuteNonQuery(sql, new SqlParameter("@id", cid));

            System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('❌ Application Rejected.');", true);
        }

        // 刷新列表
        BindData();
    }
}