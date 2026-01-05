using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

// 抑制 IDE1006 命名规则警告 (WebForms 事件命名兼容)
#pragma warning disable IDE1006

public partial class StudentHome : System.Web.UI.Page
{
    // 公开字段供前端 (.aspx) 调用，例如显示红点
    public bool HasFailed = false;

    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. 权限验证
        if (Session["Role"] == null || Session["Role"].ToString() != "Student")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            // 加载基本信息
            lblName.Text = Session["User"] != null ? Session["User"].ToString() : "Student";
            lblStuNo.Text = Session["UserNumber"] != null ? Session["UserNumber"].ToString() : "Unknown";

            LoadDashboardStats();
        }
    }

    private void LoadDashboardStats()
    {
        if (Session["UserId"] == null) return;
        string uid = Session["UserId"].ToString();

        // 1. 计算平均分和已修学分 (只计算 >0 分的课程)
        // 使用 ISNULL 处理可能为空的情况
        string sqlStats = @"
            SELECT 
                ISNULL(AVG(s.Score), 0) as AvgScore,
                ISNULL(SUM(CASE WHEN s.Score >= 60 THEN c.Credit ELSE 0 END), 0) as TotalCredits
            FROM Scores s
            JOIN Courses c ON s.CourseId = c.CourseId
            WHERE s.StudentId = @uid AND s.Score > 0";

        DataTable dtStats = SqlHelper.ExecuteQuery(sqlStats, new SqlParameter("@uid", uid));

        if (dtStats.Rows.Count > 0)
        {
            DataRow dr = dtStats.Rows[0];

            // 安全解析 double
            double avg;
            double credits;

            double.TryParse(dr["AvgScore"].ToString(), out avg);
            double.TryParse(dr["TotalCredits"].ToString(), out credits);

            ltlAvgScore.Text = avg.ToString("F1");
            ltlCredits.Text = credits.ToString("F1");
        }

        // 2. 统计挂科数 (Score < 60 且 Score > 0)
        string sqlFail = "SELECT COUNT(*) FROM Scores WHERE StudentId = @uid AND Score < 60 AND Score > 0";
        object failResult = SqlHelper.ExecuteScalar(sqlFail, new SqlParameter("@uid", uid));
        int failCount = Convert.ToInt32(failResult);

        ltlFailed.Text = failCount.ToString();

        // 3. 检查是否有“需重修”或“待审批”状态
        // RetakeStatus: 0=正常, 1=需补考, 2=申请中
        // 如果有挂科(failCount>0) 或者 状态不为0，都视为异常状态
        string sqlAlert = "SELECT COUNT(*) FROM Scores WHERE StudentId = @uid AND (RetakeStatus > 0 OR (Score < 60 AND Score > 0))";
        object alertResult = SqlHelper.ExecuteScalar(sqlAlert, new SqlParameter("@uid", uid));
        int alertCount = Convert.ToInt32(alertResult);

        // 设置前端标记 (用于控制红点/警告样式的显示)
        if (alertCount > 0)
        {
            HasFailed = true;
        }
        else
        {
            HasFailed = false;
        }
    }

    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        Response.Redirect("Login.aspx");
    }
}