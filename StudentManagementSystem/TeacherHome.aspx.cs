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
            lblName.Text = Session["User"] != null ? Session["User"].ToString() : "教师";

            LoadTerms();
            LoadMyCourses();
            CheckTodo(); // 检查待办事项（如补考审批）
        }
    }

    // --- 1. 加载学期下拉框 ---
    private void LoadTerms()
    {
        // 获取所有相关学期 (课程表 + 成绩表)
        string sql = @"
            SELECT semester AS Term FROM Courses WHERE semester IS NOT NULL
            UNION
            SELECT Term FROM Scores WHERE Term IS NOT NULL
            ORDER BY Term DESC";

        DataTable dt = SqlHelper.ExecuteQuery(sql);

        ddlTerm.DataSource = dt;
        ddlTerm.DataTextField = "Term";
        ddlTerm.DataValueField = "Term";
        ddlTerm.DataBind();

        // 默认选中第一个
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
    }

    // --- 3. 检查待办事项 (面板警报) ---
    private void CheckTodo()
    {
        // 检查是否有待审批的补考申请 (RetakeStatus = 2)
        string tid = Session["UserId"].ToString();
        string sql = @"
            SELECT COUNT(*) 
            FROM Scores s
            JOIN Courses c ON s.CourseId = c.CourseId
            WHERE s.RetakeStatus = 2 AND c.TeacherId = @tid";

        object result = SqlHelper.ExecuteScalar(sql, new SqlParameter("@tid", tid));
        int count = Convert.ToInt32(result);

        ltlTodoCount.Text = count.ToString();

        // 如果有待办，前端会根据数字显示高亮，这里仅负责赋值
    }

    // --- 4. 辅助方法：生成状态 HTML (汉化版) ---
    public string GetStatusHtml(object statusObj)
    {
        if (statusObj == null || statusObj == DBNull.Value) return "";

        int status = Convert.ToInt32(statusObj);

        // 0: 审核中, 1: 已发布
        if (status == 1)
        {
            return "<span class='badge badge-success'><i class='fas fa-check-circle'></i> 已发布</span>";
        }
        else
        {
            return "<span class='badge badge-warning'><i class='fas fa-hourglass-half'></i> 审核中</span>";
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
            // 携带课程名称跳转 (虽然 TeacherGrade 会自己查，但 URL 好看点)
            Response.Redirect("TeacherGrade.aspx?cid=" + cid);
        }
    }

    // 注销
    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        Response.Redirect("Login.aspx");
    }
}