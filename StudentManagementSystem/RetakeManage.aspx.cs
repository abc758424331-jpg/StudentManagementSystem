using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

// 抑制 IDE 命名警告
#pragma warning disable IDE1006

public partial class RetakeManage : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. 权限验证
        if (Session["Role"] == null || Session["Role"].ToString() != "Teacher")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            BindData();
        }
    }

    // --- 1. 加载待审批列表 ---
    private void BindData()
    {
        if (Session["UserId"] == null) return;
        string tid = Session["UserId"].ToString();

        // 查询逻辑：
        // 1. 关联 Students 表获取学生信息
        // 2. 关联 Courses 表确保是该教师的课
        // 3. 筛选 RetakeStatus = 2 (审核中)
        string sql = @"
            SELECT 
                s.ScoreId,
                st.StuNumber,
                st.Name AS StudentName,
                c.CourseName,
                c.Semester,
                s.Score AS OriginalScore
            FROM Scores s
            JOIN Students st ON s.StudentId = st.StudentId
            JOIN Courses c ON s.CourseId = c.CourseId
            WHERE c.TeacherId = @tid 
              AND s.RetakeStatus = 2
            ORDER BY c.CourseId, st.StuNumber";

        DataTable dt = SqlHelper.ExecuteQuery(sql, new SqlParameter("@tid", tid));
        gvRetakeList.DataSource = dt;
        gvRetakeList.DataBind();
    }

    // --- 2. 辅助：格式化分数显示 ---
    public string FormatScore(object scoreObj)
    {
        if (scoreObj == null || scoreObj == DBNull.Value) return "N/A";
        double score = Convert.ToDouble(scoreObj);

        // 逻辑自查：如果是负分，显示缺考
        if (score < 0) return "<span style='color:#ef4444'>缺考</span>";

        // 既然是补考申请，肯定是挂科的，用红色显示
        // 兼容性修复：使用 string.Format 替代 $
        return string.Format("<span style='color:#ef4444'>{0}</span>", score);
    }

    // --- 3. 审批操作 (批准/驳回) ---
    protected void gvRetakeList_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Approve" || e.CommandName == "Reject")
        {
            int scoreId = Convert.ToInt32(e.CommandArgument);
            int newStatus = (e.CommandName == "Approve") ? 3 : 4;
            // 3=已批准(Waiting for Exam), 4=已驳回

            // 逻辑自查：并发控制
            // 只有当当前状态仍为 2 (审核中) 时才更新
            // 防止学生刚刚撤回申请，老师却点了批准
            string sql = "UPDATE Scores SET RetakeStatus = @newStatus WHERE ScoreId = @id AND RetakeStatus = 2";

            try
            {
                int rows = SqlHelper.ExecuteNonQuery(sql,
                    new SqlParameter("@newStatus", newStatus),
                    new SqlParameter("@id", scoreId));

                if (rows > 0)
                {
                    string msg = (newStatus == 3) ? "✅ 已批准补考申请。" : "🚫 已驳回该申请。";

                    // 兼容性修复：使用 string.Format 替代 $
                    string js = string.Format("alert('{0}');", msg);
                    ScriptManager.RegisterStartupScript(this, GetType(), "toast", js, true);
                }
                else
                {
                    // rows == 0 说明条件不满足 (可能已经被学生撤回，或者已经被处理)
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('⚠️ 操作无效：该申请状态已变更（可能学生已撤回）。请刷新列表。');", true);
                }
            }
            catch (Exception ex)
            {
                string err = ex.Message.Replace("'", "");

                // 兼容性修复：使用 string.Format 替代 $
                string jsError = string.Format("alert('❌ 系统错误：{0}');", err);
                ScriptManager.RegisterStartupScript(this, GetType(), "error", jsError, true);
            }

            // 操作完成后刷新列表
            BindData();
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