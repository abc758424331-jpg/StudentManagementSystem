using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

// 抑制命名警告
#pragma warning disable IDE1006

public partial class StudentScore : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. 权限验证
        if (Session["Role"] == null || Session["Role"].ToString() != "Student")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            LoadTerms();
            BindData();
        }
    }

    // --- 1. 加载学期下拉框 ---
    private void LoadTerms()
    {
        if (Session["UserId"] == null) return;
        string uid = Session["UserId"].ToString();

        // 查找该学生所有有成绩的学期
        string sql = "SELECT DISTINCT Term FROM Scores WHERE StudentId = @uid ORDER BY Term DESC";
        DataTable dt = SqlHelper.ExecuteQuery(sql, new SqlParameter("@uid", uid));

        ddlTerm.DataSource = dt;
        ddlTerm.DataTextField = "Term";
        ddlTerm.DataValueField = "Term";
        ddlTerm.DataBind();

        // 如果没有数据
        if (ddlTerm.Items.Count == 0)
        {
            ddlTerm.Items.Insert(0, new ListItem("暂无成绩记录", "0"));
            ddlTerm.Enabled = false;
        }
    }

    // --- 2. 加载成绩列表 ---
    private void BindData()
    {
        if (ddlTerm.SelectedValue == "0") return;

        string uid = Session["UserId"].ToString();
        string term = ddlTerm.SelectedValue;

        // 联表查询
        string sql = @"
            SELECT s.ScoreId, s.Score, s.Term, s.RetakeStatus,
                   c.CourseName, c.Credit, c.CourseType,
                   t.Name as TeacherName
            FROM Scores s
            JOIN Courses c ON s.CourseId = c.CourseId
            LEFT JOIN Teachers t ON c.TeacherId = t.TeacherId
            WHERE s.StudentId = @uid AND s.Term = @term
            ORDER BY s.ScoreId ASC";

        DataTable dt = SqlHelper.ExecuteQuery(sql,
            new SqlParameter("@uid", uid),
            new SqlParameter("@term", term));

        gvScores.DataSource = dt;
        gvScores.DataBind();

        // 计算并显示当学期统计数据
        CalculateTermStats(dt);
    }

    // --- 3. 计算学期统计 (平均分/学分) ---
    private void CalculateTermStats(DataTable dt)
    {
        double totalScore = 0;
        double totalCredit = 0;
        int count = 0;

        foreach (DataRow dr in dt.Rows)
        {
            double score;
            if (double.TryParse(dr["Score"].ToString(), out score))
            {
                totalScore += score;
                count++;

                // 只有及格 (>=60) 才算修得学分
                if (score >= 60)
                {
                    double credit;
                    if (double.TryParse(dr["Credit"].ToString(), out credit))
                    {
                        totalCredit += credit;
                    }
                }
            }
        }

        if (count > 0)
            ltlTermAvg.Text = (totalScore / count).ToString("F1");
        else
            ltlTermAvg.Text = "0.0";

        ltlTermCredit.Text = totalCredit.ToString("F1");
    }

    // --- 4. 辅助：生成状态徽章 HTML (供前端调用) ---
    public string GetScoreStatusHtml(object scoreObj, object retakeObj)
    {
        double score = Convert.ToDouble(scoreObj);
        int retake = Convert.ToInt32(retakeObj);

        if (score >= 60)
        {
            return "<span class='badge badge-success'><i class='fas fa-check'></i> 及格</span>";
        }
        else
        {
            // 不及格情况
            if (retake == 2) return "<span class='badge badge-warning'>补考审批中</span>";
            if (retake == 3) return "<span class='badge badge-info'>重修安排中</span>";

            // 纯挂科
            return "<span class='badge badge-danger'><i class='fas fa-times'></i> 不及格</span>";
        }
    }

    // --- 5. 事件处理 ---

    protected void ddlTerm_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindData();
    }

    // 处理补考申请
    protected void gvScores_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "ApplyRetake")
        {
            int scoreId = Convert.ToInt32(e.CommandArgument);

            // RetakeStatus: 2 = 已申请
            string sql = "UPDATE Scores SET RetakeStatus = 2 WHERE ScoreId = @id";

            try
            {
                SqlHelper.ExecuteNonQuery(sql, new SqlParameter("@id", scoreId));

                BindData(); // 刷新界面

                // 弹窗提示
                System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('✅ 补考申请已提交，请等待教师审批。');", true);
            }
            catch (Exception ex)
            {
                string msg = string.Format("alert('❌ 申请失败: {0}');", ex.Message.Replace("'", ""));
                System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "alert", msg, true);
            }
        }
    }

    // 控制按钮显示 (RowDataBound)
    protected void gvScores_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            double score = Convert.ToDouble(DataBinder.Eval(e.Row.DataItem, "Score"));
            int status = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "RetakeStatus"));

            // 查找按钮
            LinkButton btn = (LinkButton)e.Row.FindControl("btnRetake");

            if (btn != null)
            {
                // 显示条件：分数<60 且 未申请(status!=2) 且 未批准(status!=3)
                if (score < 60 && status != 2 && status != 3)
                {
                    btn.Visible = true;
                }
                else
                {
                    btn.Visible = false;
                }
            }
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