using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class RetakeManage : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. 权限验证
        if (Session["Role"] == null || Session["Role"].ToString() != "Teacher")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            LoadTerms();
            LoadCourses();
            LoadApplyList();
            UpdateHUD();
        }
    }

    // --- 1. 加载学期 ---
    private void LoadTerms()
    {
        string sql = "SELECT DISTINCT Term FROM Scores ORDER BY Term DESC";
        DataTable dt = SqlHelper.ExecuteQuery(sql);

        ddlTerm.DataSource = dt;
        ddlTerm.DataTextField = "Term";
        ddlTerm.DataValueField = "Term";
        ddlTerm.DataBind();
    }

    // --- 2. 加载课程 ---
    private void LoadCourses()
    {
        int tid = Convert.ToInt32(Session["UserId"]);
        string term = ddlTerm.SelectedValue;

        string sql = "SELECT CourseId, CourseName FROM Courses WHERE TeacherId = @tid AND semester = @term";
        DataTable dt = SqlHelper.ExecuteQuery(sql,
            new SqlParameter("@tid", tid),
            new SqlParameter("@term", term));

        ddlCourse.DataSource = dt;
        ddlCourse.DataTextField = "CourseName";
        ddlCourse.DataValueField = "CourseId";
        ddlCourse.DataBind();

        ddlCourse.Items.Insert(0, new ListItem("ALL COURSES", "0"));
    }

    // --- 3. 加载申请列表 (核心修复) ---
    private void LoadApplyList()
    {
        int tid = Convert.ToInt32(Session["UserId"]);
        string term = ddlTerm.SelectedValue;
        string cid = ddlCourse.SelectedValue;

        // [关键] 必须添加 AND s.RetakeStatus = 2
        // 这样可以确保列表只显示“已申请”的学生，不会显示未申请(1)或已通过(3)的
        string sql = @"
            SELECT 
                s.ScoreId, 
                stu.StuNumber, 
                stu.Name, 
                cls.ClassName, 
                s.Score, 
                s.RetakeStatus,
                c.CourseName
            FROM Scores s
            JOIN Students stu ON s.StudentId = stu.StudentId
            LEFT JOIN Classes cls ON stu.ClassId = cls.ClassId
            JOIN Courses c ON s.CourseId = c.CourseId
            WHERE c.TeacherId = @tid 
              AND s.Term = @term
              AND s.RetakeStatus = 2";

        if (cid != "0")
        {
            sql += " AND s.CourseId = @cid";
        }

        DataTable dt;
        if (cid != "0")
            dt = SqlHelper.ExecuteQuery(sql, new SqlParameter("@tid", tid), new SqlParameter("@term", term), new SqlParameter("@cid", cid));
        else
            dt = SqlHelper.ExecuteQuery(sql, new SqlParameter("@tid", tid), new SqlParameter("@term", term));

        gvApplyList.DataSource = dt;
        gvApplyList.DataBind();
    }

    // --- 4. 辅助：生成状态HTML (前台调用) ---
    public string GetStatusHtml(object statusObj)
    {
        int status = Convert.ToInt32(statusObj);
        switch (status)
        {
            case 2:
                // 橙色
                return "<span class='badge' style='background:rgba(245, 158, 11, 0.15); color:#f59e0b; border:1px solid #f59e0b;'>PENDING APPROVAL</span>";
            case 3:
                // 绿色 (理论上列表里不会出现，但写着保险)
                return "<span class='badge' style='background:rgba(16, 185, 129, 0.15); color:#10b981; border:1px solid #10b981;'>APPROVED</span>";
            default:
                // 红色 (未申请)
                return "<span class='badge' style='background:rgba(239, 68, 68, 0.15); color:#ef4444; border:1px solid #ef4444;'>NOT APPLIED</span>";
        }
    }

    // --- 5. 更新统计 HUD ---
    private void UpdateHUD()
    {
        int tid = Convert.ToInt32(Session["UserId"]);

        string sqlPending = "SELECT COUNT(*) FROM Scores s JOIN Courses c ON s.CourseId = c.CourseId WHERE c.TeacherId=@tid AND s.RetakeStatus=2";
        ltlPending.Text = SqlHelper.ExecuteScalar(sqlPending, new SqlParameter("@tid", tid)).ToString();

        string sqlApproved = "SELECT COUNT(*) FROM Scores s JOIN Courses c ON s.CourseId = c.CourseId WHERE c.TeacherId=@tid AND s.RetakeStatus=3";
        ltlApproved.Text = SqlHelper.ExecuteScalar(sqlApproved, new SqlParameter("@tid", tid)).ToString();

        string sqlTotal = "SELECT COUNT(*) FROM Scores s JOIN Courses c ON s.CourseId = c.CourseId WHERE c.TeacherId=@tid AND s.RetakeStatus >= 2";
        ltlTotal.Text = SqlHelper.ExecuteScalar(sqlTotal, new SqlParameter("@tid", tid)).ToString();
    }

    // --- 事件处理 ---
    protected void ddlTerm_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadCourses();
        LoadApplyList();
        UpdateHUD();
    }

    protected void ddlCourse_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadApplyList();
    }

    // 单个批准
    protected void gvApplyList_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Approve")
        {
            int scoreId = Convert.ToInt32(e.CommandArgument);
            ApproveScore(scoreId);

            LoadApplyList(); // 重新加载列表，刚才批准的会消失
            UpdateHUD();
        }
    }

    // 批量批准
    protected void btnBatchApprove_Click(object sender, EventArgs e)
    {
        bool hasSelected = false;
        foreach (GridViewRow row in gvApplyList.Rows)
        {
            CheckBox chk = (CheckBox)row.FindControl("chkSelect");
            if (chk != null && chk.Checked)
            {
                int scoreId = Convert.ToInt32(gvApplyList.DataKeys[row.RowIndex].Value);
                ApproveScore(scoreId);
                hasSelected = true;
            }
        }

        if (hasSelected)
        {
            LoadApplyList();
            UpdateHUD();
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('✅ Selected requests approved!');", true);
        }
        else
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('⚠️ Please select items first.');", true);
        }
    }

    private void ApproveScore(int scoreId)
    {
        string sql = "UPDATE Scores SET RetakeStatus = 3 WHERE ScoreId = @id";
        SqlHelper.ExecuteNonQuery(sql, new SqlParameter("@id", scoreId));
    }

    protected void chkAll_CheckedChanged(object sender, EventArgs e)
    {
        CheckBox chkAll = (CheckBox)sender;
        foreach (GridViewRow row in gvApplyList.Rows)
        {
            CheckBox chk = (CheckBox)row.FindControl("chkSelect");
            if (chk != null) chk.Checked = chkAll.Checked;
        }
    }

    // [修复注销报错]
    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        Response.Redirect("Login.aspx");
    }
}