using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class CourseDetail : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. 基础登录验证
        if (Session["User"] == null || Session["UserId"] == null)
        {
            Response.Redirect("Login.aspx");
            return;
        }

        if (!IsPostBack)
        {
            // 2. 参数验证
            if (Request.QueryString["cid"] != null)
            {
                string cid = Request.QueryString["cid"];
                LoadCourseInfo(cid);
                LoadComments(cid);
            }
            else
            {
                // 无参数时的容错处理
                lblCourseName.Text = "⚠️ Course Not Found";
                btnPost.Enabled = false;
                txtComment.Enabled = false;
                txtComment.Attributes["placeholder"] = "Invalid Course ID";
            }
        }
    }

    // --- 1. 加载课程详情 ---
    private void LoadCourseInfo(string cid)
    {
        // 联表查询：获取课程基本信息 + 教师姓名 + 选课人数统计
        string sql = @"
            SELECT c.CourseName, c.Credit, c.Semester, c.CourseType, 
                   t.Name as TeacherName,
                   (SELECT COUNT(*) FROM Scores WHERE CourseId = c.CourseId) as StuCount,
                   c.MaxCapacity
            FROM Courses c
            LEFT JOIN Teachers t ON c.TeacherId = t.TeacherId
            WHERE c.CourseId = @cid";

        DataTable dt = SqlHelper.ExecuteQuery(sql, new SqlParameter("@cid", cid));

        if (dt.Rows.Count > 0)
        {
            DataRow dr = dt.Rows[0];
            lblCourseName.Text = dr["CourseName"].ToString();
        }
        else
        {
            lblCourseName.Text = "❌ Course deleted or does not exist.";
            btnPost.Enabled = false;
        }
    }

    // --- 2. 加载评论列表 ---
    private void LoadComments(string cid)
    {
        // 联表查询：获取评论内容 + 学生姓名
        // 按时间倒序排列 (最新的在最前)
        string sql = @"
            SELECT cc.Content, cc.PostTime, 
                   s.Name as StudentName
            FROM CourseComments cc
            JOIN Students s ON cc.StudentId = s.StudentId
            WHERE cc.CourseId = @cid
            ORDER BY cc.PostTime DESC";

        DataTable dt = SqlHelper.ExecuteQuery(sql, new SqlParameter("@cid", cid));

        if (dt.Rows.Count > 0)
        {
            rptComments.DataSource = dt;
            rptComments.DataBind();
            lblEmpty.Visible = false;
        }
        else
        {
            rptComments.DataSource = null;
            rptComments.DataBind();
            lblEmpty.Visible = true; // 显示“暂无留言”提示
        }
    }

    // --- 3. 发布评论 ---
    protected void btnPost_Click(object sender, EventArgs e)
    {
        string content = txtComment.Text.Trim();
        string cid = Request.QueryString["cid"];
        string uid = Session["UserId"].ToString();

        // 空校验
        if (string.IsNullOrEmpty(content)) return;

        // 仅允许学生发表评论
        if (Session["Role"] != null && Session["Role"].ToString() == "Student")
        {
            string sql = "INSERT INTO CourseComments (CourseId, StudentId, Content, PostTime) VALUES (@cid, @uid, @txt, GETDATE())";

            try
            {
                SqlHelper.ExecuteNonQuery(sql,
                    new SqlParameter("@cid", cid),
                    new SqlParameter("@uid", uid),
                    new SqlParameter("@txt", content));

                // 成功后清空输入框并刷新列表
                txtComment.Text = "";
                LoadComments(cid);
            }
            catch (Exception ex)
            {
                // [修复] 使用 string.Format 替代 $ 字符串插值，解决编译器版本报错
                string err = ex.Message.Replace("'", "").Replace("\r\n", "");
                string js = string.Format("alert('❌ Post Failed: {0}');", err);
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", js, true);
            }
        }
        else
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('⚠️ Only enrolled students can post comments.');", true);
        }
    }
}