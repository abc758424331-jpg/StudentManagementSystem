using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

// 抑制 IDE 命名警告
#pragma warning disable IDE1006

public partial class CourseApproval : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. 权限验证 (仅限管理员)
        if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            BindData();
        }
    }

    // --- 1. 加载待审批课程列表 ---
    private void BindData()
    {
        // 查询逻辑：
        // 1. 联表 Teachers 获取教师详情
        // 2. 筛选 Status = 0 (待审核)
        // 3. 按提交时间(ID)倒序排列
        string sql = @"
            SELECT 
                c.CourseId, 
                c.CourseName, 
                c.Credit, 
                c.Semester, 
                c.MaxCapacity,
                t.Name AS TeacherName, 
                t.WorkNo
            FROM Courses c
            JOIN Teachers t ON c.TeacherId = t.TeacherId
            WHERE c.Status = 0
            ORDER BY c.CourseId DESC";

        DataTable dt = SqlHelper.ExecuteQuery(sql);
        gvCourses.DataSource = dt;
        gvCourses.DataBind();
    }

    // --- 2. 审批操作处理 ---
    protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Approve" || e.CommandName == "Reject")
        {
            int courseId = Convert.ToInt32(e.CommandArgument);
            string sql = "";
            string msg = "";

            if (e.CommandName == "Approve")
            {
                // 批准：状态置为 1 (已发布)
                // 逻辑自查：增加 AND Status=0 确保只处理待审核的记录
                sql = "UPDATE Courses SET Status = 1 WHERE CourseId = @id AND Status = 0";
                msg = "✅ 课程审批通过，已正式发布上线！";
            }
            else
            {
                // 驳回：直接删除记录
                // 设计考量：如果保留记录但设为其他状态(如2)，需同步修改教师端显示逻辑。
                // 为保持系统稳定性，此处采取“驳回即退回”策略（删除），教师需重新提交。
                sql = "DELETE FROM Courses WHERE CourseId = @id AND Status = 0";
                msg = "🚫 课程申请已驳回（记录已移除）。";
            }

            try
            {
                int rows = SqlHelper.ExecuteNonQuery(sql, new SqlParameter("@id", courseId));

                if (rows > 0)
                {
                    // 使用 string.Format 兼容 C# 5.0
                    string js = string.Format("alert('{0}');", msg);
                    ScriptManager.RegisterStartupScript(this, GetType(), "toast", js, true);
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('⚠️ 操作无效：该申请可能已被处理或撤销。');", true);
                }
            }
            catch (Exception ex)
            {
                string err = ex.Message.Replace("'", "");
                string jsError = string.Format("alert('❌ 系统错误：{0}');", err);
                ScriptManager.RegisterStartupScript(this, GetType(), "error", jsError, true);
            }

            // 刷新列表
            BindData();
        }
    }

    // --- 退出登录 ---
    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        Response.Redirect("Login.aspx");
    }
}