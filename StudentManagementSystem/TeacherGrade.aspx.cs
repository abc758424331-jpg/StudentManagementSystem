using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

// 抑制 IDE 命名警告
#pragma warning disable IDE1006

public partial class TeacherGrade : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. 身份验证
        if (Session["Role"] == null || Session["Role"].ToString() != "Teacher")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            // 获取 URL 参数中的 CourseId
            if (Request.QueryString["cid"] != null)
            {
                string cid = Request.QueryString["cid"];
                LoadCourseInfo(cid);
                BindStudentList(cid);
            }
            else
            {
                // 如果没有参数，非法访问，跳回主页
                Response.Redirect("TeacherHome.aspx");
            }
        }
    }

    // --- 1. 加载课程基本信息 (防止教师不知道在给哪门课打分) ---
    private void LoadCourseInfo(string cid)
    {
        string sql = "SELECT CourseName, Semester FROM Courses WHERE CourseId = @cid";
        DataTable dt = SqlHelper.ExecuteQuery(sql, new SqlParameter("@cid", cid));

        if (dt.Rows.Count > 0)
        {
            // 给前端控件赋值，确保信息展示出来
            lblCourseName.Text = dt.Rows[0]["CourseName"].ToString();
            lblTerm.Text = dt.Rows[0]["Semester"].ToString();
        }
        else
        {
            // 课程不存在
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('❌ 课程未找到！');window.location='TeacherHome.aspx';", true);
        }
    }

    // --- 2. 加载学生列表 ---
    private void BindStudentList(string cid)
    {
        // 关联 Scores 和 Students 表，获取该课程下的所有学生及其当前成绩
        // 逻辑自查：确保显示学号和姓名，方便核对
        string sql = @"
            SELECT 
                s.ScoreId,
                st.StuNumber, 
                st.Name, 
                s.Score 
            FROM Scores s
            JOIN Students st ON s.StudentId = st.StudentId
            WHERE s.CourseId = @cid
            ORDER BY st.StuNumber ASC";

        DataTable dt = SqlHelper.ExecuteQuery(sql, new SqlParameter("@cid", cid));
        gvStudents.DataSource = dt;
        gvStudents.DataBind();
    }

    // --- 3. 批量保存成绩 ---
    protected void btnSave_Click(object sender, EventArgs e)
    {
        int successCount = 0;
        string errorMsg = "";

        // 遍历 GridView 的每一行进行保存
        foreach (GridViewRow row in gvStudents.Rows)
        {
            if (row.RowType == DataControlRowType.DataRow)
            {
                // 获取控件 (对应前端 ItemTemplate)
                HiddenField hfScoreId = (HiddenField)row.FindControl("hfScoreId");
                TextBox txtScore = (TextBox)row.FindControl("txtScore");
                Label lblName = (Label)row.FindControl("lblName"); // 用于报错时指出是谁

                if (hfScoreId != null && txtScore != null)
                {
                    string scoreText = txtScore.Text.Trim();
                    int scoreId = Convert.ToInt32(hfScoreId.Value);

                    // 逻辑自查：如果是空值，则跳过不更新 (防止误删成绩)
                    // 如果需要删除成绩，通常需要专门的“重置”功能，防止手误
                    if (string.IsNullOrEmpty(scoreText))
                    {
                        continue;
                    }

                    // A. 数字格式验证
                    double scoreVal;
                    if (!double.TryParse(scoreText, out scoreVal))
                    {
                        errorMsg += string.Format("【{0}】分数格式错误; ", lblName.Text);
                        continue;
                    }

                    // B. 逻辑范围验证 (防止 -10 或 1000 分)
                    if (scoreVal < 0 || scoreVal > 100)
                    {
                        errorMsg += string.Format("【{0}】分数必须在 0-100 之间; ", lblName.Text);
                        continue;
                    }

                    // C. 更新数据库
                    // 注意：更新成绩时，将 RetakeStatus 重置为 0，
                    // 逻辑：因为如果是补考后录入成绩，此时应该视为“已完结”，或者是新的正常成绩
                    string sql = "UPDATE Scores SET Score = @sc, RetakeStatus = 0 WHERE ScoreId = @id";

                    try
                    {
                        SqlHelper.ExecuteNonQuery(sql,
                            new SqlParameter("@sc", scoreVal),
                            new SqlParameter("@id", scoreId));
                        successCount++;
                    }
                    catch (Exception ex)
                    {
                        errorMsg += "数据库错误: " + ex.Message + "; ";
                    }
                }
            }
        }

        // 保存后重新加载数据，刷新界面显示
        if (Request.QueryString["cid"] != null)
        {
            BindStudentList(Request.QueryString["cid"]);
        }

        // D. 结果反馈
        if (!string.IsNullOrEmpty(errorMsg))
        {
            // 有错误发生
            string js = string.Format("alert('⚠️ 部分保存失败：\\n{0}');", errorMsg.Replace("'", ""));
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", js, true);
        }
        else
        {
            // 全部成功
            string js = string.Format("alert('✅ 批量操作完成！\\n成功保存 {0} 条成绩记录。');", successCount);
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", js, true);
        }
    }

    // --- 返回按钮 ---
    protected void btnBack_Click(object sender, EventArgs e)
    {
        Response.Redirect("TeacherHome.aspx");
    }

    // --- 注销 ---
    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        Response.Redirect("Login.aspx");
    }
}