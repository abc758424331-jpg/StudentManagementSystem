using System;
using System.Data;
using System.Data.SqlClient;
using System.Drawing; // 用于 Color

public partial class CourseConfig : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 权限验证
        if (Session["Role"] == null || Session["Role"].ToString() != "Teacher")
            Response.Redirect("Login.aspx");

        if (!IsPostBack)
        {
            lblName.Text = Session["User"].ToString();

            // 获取 URL 参数中的 CourseId
            if (Request.QueryString["cid"] != null)
            {
                string cid = Request.QueryString["cid"];
                lblCourseId.Text = cid;
                LoadConfig(cid);
            }
            else
            {
                lblMsg.Text = "⚠️ Missing Course ID Parameter";
                lblMsg.ForeColor = Color.Red;
                btnSave.Enabled = false;
            }
        }
    }

    private void LoadConfig(string cid)
    {
        string sql = "SELECT WeightRegular, WeightHomework, WeightMidterm, WeightFinal FROM Courses WHERE CourseId = @cid";
        DataTable dt = SqlHelper.ExecuteQuery(sql, new SqlParameter("@cid", cid));

        if (dt.Rows.Count > 0)
        {
            DataRow dr = dt.Rows[0];
            txtRegular.Text = dr["WeightRegular"].ToString();
            txtHomework.Text = dr["WeightHomework"].ToString();
            txtMidterm.Text = dr["WeightMidterm"].ToString();
            txtFinal.Text = dr["WeightFinal"].ToString();
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        string cid = lblCourseId.Text;

        // 声明变量 (兼容 C# 5.0)
        int wReg, wHwk, wMid, wFin;

        bool b1 = int.TryParse(txtRegular.Text, out wReg);
        bool b2 = int.TryParse(txtHomework.Text, out wHwk);
        bool b3 = int.TryParse(txtMidterm.Text, out wMid);
        bool b4 = int.TryParse(txtFinal.Text, out wFin);

        if (!b1 || !b2 || !b3 || !b4)
        {
            ShowMsg("❌ All weights must be valid integers.", false);
            return;
        }

        if ((wReg + wHwk + wMid + wFin) != 100)
        {
            ShowMsg("⚠️ Total weight must equal 100%. Current: " + (wReg + wHwk + wMid + wFin), false);
            return;
        }

        string sql = @"UPDATE Courses SET 
                       WeightRegular = @w1, 
                       WeightHomework = @w2, 
                       WeightMidterm = @w3, 
                       WeightFinal = @w4 
                       WHERE CourseId = @cid";

        try
        {
            SqlHelper.ExecuteNonQuery(sql,
                new SqlParameter("@w1", wReg),
                new SqlParameter("@w2", wHwk),
                new SqlParameter("@w3", wMid),
                new SqlParameter("@w4", wFin),
                new SqlParameter("@cid", cid));

            ShowMsg("✅ Calibration Applied Successfully!", true);
        }
        catch (Exception ex)
        {
            ShowMsg("❌ System Error: " + ex.Message, false);
        }
    }

    private void ShowMsg(string msg, bool isSuccess)
    {
        lblMsg.Text = msg;
        lblMsg.ForeColor = isSuccess ? Color.LimeGreen : Color.Red;
    }

    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Response.Redirect("Login.aspx");
    }
}