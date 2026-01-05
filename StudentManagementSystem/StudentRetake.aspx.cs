using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

// 抑制 IDE 命名警告
#pragma warning disable IDE1006

public partial class StudentRetake : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. 权限验证
        if (Session["Role"] == null || Session["Role"].ToString() != "Student")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            BindData();
        }
    }

    // --- 1. 加载申请列表 ---
    private void BindData()
    {
        if (Session["UserId"] == null) return;
        string uid = Session["UserId"].ToString();

        // 查询逻辑：
        // 查出所有不及格 (<60) 或者 已经有补考状态 (>0) 的记录
        // 这样不仅能看申请中的，也能看哪些挂了还没申请
        string sql = @"
            SELECT 
                s.ScoreId, 
                s.CourseId, 
                s.Score, 
                s.RetakeStatus,
                c.CourseName, 
                c.Credit,
                t.Name as TeacherName
            FROM Scores s
            JOIN Courses c ON s.CourseId = c.CourseId
            LEFT JOIN Teachers t ON c.TeacherId = t.TeacherId
            WHERE s.StudentId = @uid 
              AND (s.Score < 60 OR s.RetakeStatus > 0)
            ORDER BY s.RetakeStatus DESC, s.Term DESC";

        DataTable dt = SqlHelper.ExecuteQuery(sql, new SqlParameter("@uid", uid));
        gvRetake.DataSource = dt;
        gvRetake.DataBind();
    }

    // --- 2. 状态显示辅助方法 (供前端调用) ---
    public string GetStatusHtml(object statusObj)
    {
        if (statusObj == null || statusObj == DBNull.Value) return "<span class='badge badge-gray'>未知</span>";

        int status = Convert.ToInt32(statusObj);

        // 状态定义:
        // 0 = 初始/挂科未申请
        // 2 = 申请审核中
        // 3 = 已通过/已安排
        // 4 = 已驳回 (预留)

        switch (status)
        {
            case 2:
                return "<span class='badge badge-warning'><i class='fas fa-clock'></i> 审核中</span>";
            case 3:
                return "<span class='badge badge-success'><i class='fas fa-check-circle'></i> 已批准</span>";
            case 4:
                return "<span class='badge badge-danger'><i class='fas fa-times-circle'></i> 已驳回</span>";
            default:
                // 状态0，且出现在这个列表里，说明是挂科了但还没申请
                return "<span class='badge badge-secondary'>未申请</span>";
        }
    }

    // --- 3. 格式化分数显示 ---
    public string FormatScore(object scoreObj)
    {
        if (scoreObj == null || scoreObj == DBNull.Value) return "-";

        double score = Convert.ToDouble(scoreObj);

        // 逻辑自查：负分通常代表缺考或作弊，显示为特定文本更友好
        if (score < 0) return "缺考";

        return score.ToString();
    }

    // --- 4. 行命令处理 (撤销申请) ---
    protected void gvRetake_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "CancelApply")
        {
            int scoreId = Convert.ToInt32(e.CommandArgument);

            // 逻辑自查：撤销前必须再次检查当前状态
            // 防止：学生打开页面停流很久，期间老师已经审批通过，此时再点撤销应该失败
            string checkSql = "SELECT RetakeStatus FROM Scores WHERE ScoreId = @id";
            object statusObj = SqlHelper.ExecuteScalar(checkSql, new SqlParameter("@id", scoreId));

            if (statusObj != null)
            {
                int currentStatus = Convert.ToInt32(statusObj);
                if (currentStatus != 2)
                {
                    // 如果状态变了 (比如变成了3-已通过)，则禁止撤销
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('❌ 操作失败：该申请已被审批处理，无法撤回。');", true);
                    BindData(); // 刷新显示最新状态
                    return;
                }
            }

            // 执行撤销 (状态回归 0)
            string updateSql = "UPDATE Scores SET RetakeStatus = 0 WHERE ScoreId = @id";

            try
            {
                SqlHelper.ExecuteNonQuery(updateSql, new SqlParameter("@id", scoreId));
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('✅ 申请已撤回。');", true);
                BindData(); // 刷新列表
            }
            catch (Exception ex)
            {
                string msg = ex.Message.Replace("'", "");
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", string.Format("alert('❌ 系统错误：{0}');", msg), true);
            }
        }
    }

    // --- 5. 动态显示/隐藏按钮 (RowDataBound) ---
    protected void gvRetake_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            // 获取数据
            int status = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "RetakeStatus"));

            // 查找“撤销”按钮
            LinkButton btnCancel = (LinkButton)e.Row.FindControl("btnCancel");

            if (btnCancel != null)
            {
                // 只有状态为 2 (审核中) 时，才允许撤销
                // 其他状态 (未申请、已通过、已驳回) 都隐藏按钮
                btnCancel.Visible = (status == 2);
            }
        }
    }

    // --- 注销 ---
    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        Response.Redirect("Login.aspx");
    }
}