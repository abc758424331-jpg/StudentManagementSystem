using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;             // 必须引用，解决 DataBinder 问题
using System.Web.UI.WebControls;
using System.Drawing;

public partial class TeacherGrade : System.Web.UI.Page
{
    // 全局变量暂存权重
    protected double wReg = 0, wHwk = 0, wMid = 0, wFin = 0;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["Role"] == null || Session["Role"].ToString() != "Teacher")
            Response.Redirect("Login.aspx");

        if (Request.QueryString["cid"] != null)
        {
            string cid = Request.QueryString["cid"];
            LoadWeights(cid);
        }

        if (!IsPostBack)
        {
            if (Request.QueryString["cid"] != null)
            {
                string cid = Request.QueryString["cid"];
                string cname = Request.QueryString["cname"] ?? "Course";

                lblCourseId.Text = cid;
                lblCourseName.Text = cname;

                LoadStudents(cid);
            }
        }
    }

    private void LoadWeights(string cid)
    {
        string sql = "SELECT WeightRegular, WeightHomework, WeightMidterm, WeightFinal FROM Courses WHERE CourseId = @cid";
        DataTable dt = SqlHelper.ExecuteQuery(sql, new SqlParameter("@cid", cid));

        if (dt.Rows.Count > 0)
        {
            DataRow dr = dt.Rows[0];

            lblWReg.Text = dr["WeightRegular"].ToString();
            lblWHwk.Text = dr["WeightHomework"].ToString();
            lblWMid.Text = dr["WeightMidterm"].ToString();
            lblWFin.Text = dr["WeightFinal"].ToString();

            double.TryParse(dr["WeightRegular"].ToString(), out wReg); wReg /= 100;
            double.TryParse(dr["WeightHomework"].ToString(), out wHwk); wHwk /= 100;
            double.TryParse(dr["WeightMidterm"].ToString(), out wMid); wMid /= 100;
            double.TryParse(dr["WeightFinal"].ToString(), out wFin); wFin /= 100;
        }
    }

    private void LoadStudents(string cid)
    {
        string sql = @"
            SELECT 
                s.ScoreId, 
                stu.StuNumber, 
                stu.Name, 
                ISNULL(s.ScoreRegular, 0) as ScoreRegular, 
                ISNULL(s.ScoreHomework, 0) as ScoreHomework, 
                ISNULL(s.ScoreMidterm, 0) as ScoreMidterm, 
                ISNULL(s.ScoreFinal, 0) as ScoreFinal, 
                ISNULL(s.Score, 0) as Score,
                ISNULL(s.IsLocked, 0) as IsLocked 
            FROM Scores s
            JOIN Students stu ON s.StudentId = stu.StudentId
            WHERE s.CourseId = @cid
            ORDER BY stu.StuNumber ASC";

        DataTable dt = SqlHelper.ExecuteQuery(sql, new SqlParameter("@cid", cid));
        gvGrades.DataSource = dt;
        gvGrades.DataBind();
    }

    // --- [修复] 方法名首字母大写，符合规范 ---
    protected void GvGrades_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            TextBox tReg = (TextBox)e.Row.FindControl("txtReg");
            TextBox tHwk = (TextBox)e.Row.FindControl("txtHwk");
            TextBox tMid = (TextBox)e.Row.FindControl("txtMid");
            TextBox tFin = (TextBox)e.Row.FindControl("txtFin");
            Button btn = (Button)e.Row.FindControl("btnSaveOne");

            // [修复] 使用完整命名空间 System.Web.UI.DataBinder
            int isLocked = Convert.ToInt32(System.Web.UI.DataBinder.Eval(e.Row.DataItem, "IsLocked"));

            if (isLocked == 1)
            {
                DisableInputs(tReg, tHwk, tMid, tFin);
                btn.Text = "UNLOCK REQUEST";
                btn.CommandName = "RequestUnlock";
                btn.CssClass = "btn-row-save";
                btn.Style.Add("border-color", "#f59e0b");
                btn.Style.Add("color", "#f59e0b");
                btn.Style.Add("background", "rgba(245, 158, 11, 0.1)");
            }
            else if (isLocked == 2)
            {
                DisableInputs(tReg, tHwk, tMid, tFin);
                btn.Text = "WAITING ADMIN";
                btn.Enabled = false;
                btn.CssClass = "btn-row-save";
                btn.Style.Add("border-color", "#64748b");
                btn.Style.Add("color", "#64748b");
            }
            else
            {
                if (wReg <= 0) LockZeroWeight(tReg);
                if (wHwk <= 0) LockZeroWeight(tHwk);
                if (wMid <= 0) LockZeroWeight(tMid);
                if (wFin <= 0) LockZeroWeight(tFin);
            }
        }
    }

    private void DisableInputs(params TextBox[] txts)
    {
        foreach (var t in txts)
        {
            t.Enabled = false;
            t.CssClass += " disabled";
        }
    }

    private void LockZeroWeight(TextBox t)
    {
        t.Enabled = false;
        t.CssClass += " disabled";
        t.Text = "0";
    }

    // --- [修复] 方法名首字母大写 ---
    protected void GvGrades_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int rowIndex = Convert.ToInt32(e.CommandArgument);
        int scoreId = Convert.ToInt32(gvGrades.DataKeys[rowIndex].Value);
        string cid = Request.QueryString["cid"];

        if (e.CommandName == "SaveOne")
        {
            GridViewRow row = gvGrades.Rows[rowIndex];
            TextBox tReg = (TextBox)row.FindControl("txtReg");
            TextBox tHwk = (TextBox)row.FindControl("txtHwk");
            TextBox tMid = (TextBox)row.FindControl("txtMid");
            TextBox tFin = (TextBox)row.FindControl("txtFin");

            double reg = ParseScore(tReg.Text);
            double hwk = ParseScore(tHwk.Text);
            double mid = ParseScore(tMid.Text);
            double fin = ParseScore(tFin.Text);

            double total = (reg * wReg) + (hwk * wHwk) + (mid * wMid) + (fin * wFin);
            total = Math.Round(total, 1);

            string sql = @"UPDATE Scores SET 
                           ScoreRegular=@r, ScoreHomework=@h, ScoreMidterm=@m, ScoreFinal=@f, Score=@t,
                           IsLocked = 1 
                           WHERE ScoreId=@id";

            SqlHelper.ExecuteNonQuery(sql,
                new SqlParameter("@r", reg),
                new SqlParameter("@h", hwk),
                new SqlParameter("@m", mid),
                new SqlParameter("@f", fin),
                new SqlParameter("@t", total),
                new SqlParameter("@id", scoreId));

            LoadStudents(cid);
            System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('✅ Grade Saved & Locked! Contact Admin to modify.');", true);
        }
        else if (e.CommandName == "RequestUnlock")
        {
            string sql = "UPDATE Scores SET IsLocked = 2 WHERE ScoreId = @id";
            SqlHelper.ExecuteNonQuery(sql, new SqlParameter("@id", scoreId));

            LoadStudents(cid);
            System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('📨 Unlock Request Sent to Admin!');", true);
        }
    }

    private double ParseScore(string text)
    {
        double val;
        if (double.TryParse(text, out val))
        {
            if (val < 0) return 0;
            if (val > 100) return 100;
            return val;
        }
        return 0;
    }
}