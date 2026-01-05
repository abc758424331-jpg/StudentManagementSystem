using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class TeacherHome : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. 权限验证
        if (Session["Role"] == null || Session["Role"].ToString() != "Teacher")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            lblName.Text = Session["User"] != null ? Session["User"].ToString() : "Teacher";

            LoadTerms();
            LoadMyCourses();
            CheckTodo(); // 检查待办事项（如补考审批）
        }
    }

    // --- 1. 加载学期下拉框 ---
    private void LoadTerms()
    {
        // 获取该教师名下课程涉及的所有学期
        string tid = Session["UserId"].ToString();
        string sql = "SELECT DISTINCT semester FROM Courses WHERE TeacherId = @tid ORDER BY semester DESC";

        DataTable dt = SqlHelper.ExecuteQuery(sql, new SqlParameter("@tid", tid));

        ddlTerm.DataSource = dt;
        ddlTerm.DataTextField = "semester";
        ddlTerm.DataValueField = "semester";
        ddlTerm.DataBind();

        // 默认加载最新学期
        if (ddlTerm.Items.Count > 0)
        {
            ddlTerm.SelectedIndex = 0;
        }
    }

    // --- 2. 加载我的课程列表 ---
    private void LoadMyCourses()
    {
        string tid = Session["UserId"].ToString();
        string term = ddlTerm.SelectedValue;

        // 查询课程信息 + 选课人数
        string sql = @"
            SELECT c.CourseId, c.CourseName, c.Credit, c.MaxCapacity, c.Status,
                   (SELECT COUNT(*) FROM Scores s WHERE s.CourseId = c.CourseId) as StudentCount
            FROM Courses c
            WHERE c.TeacherId = @tid AND c.semester = @term
            ORDER BY c.CourseId DESC";

        DataTable dt = SqlHelper.ExecuteQuery(sql,
            new SqlParameter("@tid", tid),
            new SqlParameter("@term", term));

        gvMyCourses.DataSource = dt;
        gvMyCourses.DataBind();

        // 根据是否有数据控制“空状态”显示
        if (dt.Rows.Count == 0)
        {
            // 如果需要显示空模板，GridView会自动处理 EmptyDataTemplate
            // 这里可以留空
        }
    }

    // --- 3. 检查待办事项 (HUD Alert) ---
    private void CheckTodo()
    {
        // 检查是否有待审批的补考申请 (RetakeStatus = 2)
        // 仅检查当前教师名下的课程
        string tid = Session["UserId"].ToString();
        string sql = @"
            SELECT COUNT(*) 
            FROM Scores s
            JOIN Courses c ON s.CourseId = c.CourseId
            WHERE s.RetakeStatus = 2 AND c.TeacherId = @tid";

        object result = SqlHelper.ExecuteScalar(sql, new SqlParameter("@tid", tid));
        int count = Convert.ToInt32(result);

        ltlTodoCount.Text = count.ToString();

        // 如果有待办，给面板添加警报样式 (CSS类名 card-alert 需要在 CSS 中定义，或者这里仅作逻辑处理)
        if (count > 0)
        {
            pnlTodo.CssClass += " card-alert";
        }
    }

    // --- 4. 辅助方法：生成状态 HTML (解决 GetStatusHtml 报错) ---
    // 前端 <%# GetStatusHtml(Eval("Status")) %> 调用此方法
    public string GetStatusHtml(object statusObj)
    {
        if (statusObj == null || statusObj == DBNull.Value) return "";

        int status = Convert.ToInt32(statusObj);

        // 0: 审核中 (Pending), 1: 已发布 (Published)
        if (status == 1)
        {
            return "<span class='badge badge-success'><i class='fas fa-check-circle'></i> Published</span>";
        }
        else
        {
            return "<span class='badge badge-warning'><i class='fas fa-hourglass-half'></i> Auditing</span>";
        }
    }

    // --- 5. 事件处理 ---

    // 学期切换
    protected void ddlTerm_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadMyCourses();
    }

    // 表格行命令 (配置课程 / 录入成绩)
    protected void gvMyCourses_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        string cid = e.CommandArgument.ToString();

        if (e.CommandName == "Config")
        {
            Response.Redirect("CourseConfig.aspx?cid=" + cid);
        }
        else if (e.CommandName == "Grade")
        {
            // 获取课程名称用于显示 (可选)
            GridViewRow row = (GridViewRow)((Control)e.CommandSource).NamingContainer;
            // 假设 CourseName 在第1列 (索引0)
            // 如果用了 TemplateField，需要根据实际结构获取，这里简单传 ID 即可，TeacherGrade 会自己查
            Response.Redirect("TeacherGrade.aspx?cid=" + cid);
        }
    }

    // 注销
    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Response.Redirect("Login.aspx");
    }
}