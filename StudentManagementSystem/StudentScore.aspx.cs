using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

// 抑制 IDE1006 命名规则警告，兼容 WebForms 事件命名
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

        // 如果没有数据，显示提示
        if (ddlTerm.Items.Count == 0)
        {
            ddlTerm.Items.Insert(0, new ListItem("No Records", "0"));
            ddlTerm.Enabled = false;
        }
    }

    // --- 2. 加载成绩列表 ---
    private void BindData()
    {
        if (ddlTerm.SelectedValue == "0") return;

        string uid = Session["UserId"].ToString();
        string term = ddlTerm.SelectedValue;

        // 联表查询：成绩信息 + 课程信息 + 教师信息
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

        CalculateTermStats(dt);
    }

    // --- 3. 计算学期统计数据 (平均分/总学分) ---
    private void CalculateTermStats(DataTable dt)
    {
        double totalScore = 0;
        double totalCredit = 0;
        int count = 0;

        foreach (DataRow dr in dt.Rows)
        {
            // 解析分数
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

    // --- 4. 事件处理 ---

    // 学期筛选改变
    protected void ddlTerm_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindData();
    }

    // 表格行命令 (处理重修/补考申请)
    protected void gvScores_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "ApplyRetake")
        {
            int scoreId = Convert.ToInt32(e.CommandArgument);

            // 更新状态为 2 (已申请)
            // RetakeStatus: 0=正常, 1=需补考, 2=已申请, 3=已批准
            string sql = "UPDATE Scores SET RetakeStatus = 2 WHERE ScoreId = @id";

            try
            {
                SqlHelper.ExecuteNonQuery(sql, new SqlParameter("@id", scoreId));

                BindData(); // 刷新界面

                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('✅ Retake application submitted.');", true);
            }
            catch (Exception ex)
            {
                string err = ex.Message.Replace("'", "");
                string js = string.Format("alert('❌ Error: {0}');", err);
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", js, true);
            }
        }
    }

    // 行数据绑定 (智能控制按钮显示)
    protected void gvScores_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            // 获取数据
            object scoreObj = DataBinder.Eval(e.Row.DataItem, "Score");
            object retakeObj = DataBinder.Eval(e.Row.DataItem, "RetakeStatus");

            double score = 0;
            double.TryParse(scoreObj.ToString(), out score);
            int status = Convert.ToInt32(retakeObj);

            // 查找按钮 (确保前端 GridView 中 Button 的 ID 为 btnRetake)
            Button btnRetake = (Button)e.Row.FindControl("btnRetake");

            if (btnRetake != null)
            {
                // 只有不及格 (<60) 且 未申请 (Status!=2) 且 未通过 (Status!=3) 才显示按钮
                if (score < 60 && status != 2 && status != 3)
                {
                    btnRetake.Visible = true;
                }
                else
                {
                    btnRetake.Visible = false;
                }
            }
        }
    }
}