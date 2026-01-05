using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

namespace StudentManagementSystem
{
    // 注意：类名必须与前端 Inherits 属性完全一致
    public partial class AddStudent : System.Web.UI.Page
    {
        // C# 5.0 兼容写法：获取连接字符串
        private string GetConnStr()
        {
            if (ConfigurationManager.ConnectionStrings["StudentConnString"] != null)
            {
                return ConfigurationManager.ConnectionStrings["StudentConnString"].ConnectionString;
            }
            // 兜底：如果配置文件没写，使用默认字符串
            return "Data Source=.;Initial Catalog=Jiangbaomi;Integrated Security=True";
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // 权限验证 (可选，防止未登录直接访问)
            // if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            // {
            //     Response.Redirect("Login.aspx");
            // }

            if (!IsPostBack)
            {
                BindData();
            }
        }

        /// <summary>
        /// 加载数据列表
        /// </summary>
        private void BindData()
        {
            string connStr = GetConnStr();
            // 核心逻辑：确保查询字段包含 ClassId，与前端 GridView 对应
            string sql = "SELECT StudentId, StuNumber, Name, Gender, ClassId, Phone FROM Students ORDER BY StudentId DESC";

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(sql, conn))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        gvStudents.DataSource = dt;
                        gvStudents.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                ShowAlert(string.Format("列表加载失败：{0}", ex.Message.Replace("'", "")));
            }
        }

        /// <summary>
        /// 添加按钮点击事件
        /// </summary>
        protected void btnAdd_Click(object sender, EventArgs e)
        {
            // 1. 获取输入 (Trim 去除首尾空格)
            string stuNumber = txtStuNumber.Text.Trim();
            string name = txtName.Text.Trim();
            string gender = ddlGender.SelectedValue;
            string classInput = txtClassId.Text.Trim();
            string phone = txtPhone.Text.Trim();

            // 2. 逻辑校验层 (Validation Logic)

            // A. 必填项检查
            if (string.IsNullOrEmpty(stuNumber) || string.IsNullOrEmpty(name))
            {
                ShowAlert("❌ 错误：学号和姓名不能为空！");
                return;
            }

            // B. 班级ID 数字与范围校验
            int classId = 0;
            if (!int.TryParse(classInput, out classId))
            {
                ShowAlert("❌ 格式错误：班级ID必须填写数字！");
                return;
            }
            // 逻辑自查：班级ID不能为负数
            if (classId <= 0)
            {
                ShowAlert("❌ 逻辑错误：班级ID必须大于0！");
                return;
            }

            // C. 手机号长度校验
            if (!string.IsNullOrEmpty(phone) && phone.Length != 11)
            {
                ShowAlert("⚠️ 格式警告：请输入11位手机号码！");
                return;
            }

            // D. 学号查重 (防止数据库主键冲突)
            if (IsStuNumberExists(stuNumber))
            {
                ShowAlert(string.Format("⛔ 操作拦截：学号 {0} 已存在，请勿重复添加！", stuNumber));
                return;
            }

            // 3. 数据库插入
            string connStr = GetConnStr();
            string sql = @"INSERT INTO Students (StuNumber, Name, Gender, ClassId, Phone, Password) 
                           VALUES (@StuNumber, @Name, @Gender, @ClassId, @Phone, '123456')";

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        // 使用参数化查询防止 SQL 注入
                        cmd.Parameters.AddWithValue("@StuNumber", stuNumber);
                        cmd.Parameters.AddWithValue("@Name", name);
                        cmd.Parameters.AddWithValue("@Gender", gender);
                        cmd.Parameters.AddWithValue("@ClassId", classId);

                        // 处理 Phone 为空的情况
                        if (string.IsNullOrEmpty(phone))
                            cmd.Parameters.AddWithValue("@Phone", DBNull.Value);
                        else
                            cmd.Parameters.AddWithValue("@Phone", phone);

                        conn.Open();
                        int rows = cmd.ExecuteNonQuery();

                        if (rows > 0)
                        {
                            ShowAlert("✅ 添加成功！");
                            ClearInputs(); // 清空输入框
                            BindData();    // 刷新列表
                        }
                        else
                        {
                            ShowAlert("❌ 添加失败，未写入数据库。");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowAlert(string.Format("系统错误：{0}", ex.Message.Replace("'", "")));
            }
        }

        /// <summary>
        /// 表格行命令事件 (处理删除)
        /// </summary>
        protected void gvStudents_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Del")
            {
                // 获取要删除的学生 ID
                int studentId = Convert.ToInt32(e.CommandArgument);
                DeleteStudent(studentId);
            }
        }

        /// <summary>
        /// 删除逻辑
        /// </summary>
        private void DeleteStudent(int studentId)
        {
            string connStr = GetConnStr();
            string sql = "DELETE FROM Students WHERE StudentId = @StudentId";

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@StudentId", studentId);
                        conn.Open();
                        int rows = cmd.ExecuteNonQuery();

                        if (rows > 0)
                        {
                            ShowAlert("✅ 删除成功。");
                            BindData();
                        }
                        else
                        {
                            ShowAlert("⚠️ 删除失败：数据可能已被移除。");
                            BindData();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // 逻辑自查：外键约束保护
                if (ex.Message.Contains("REFERENCE") || ex.Message.Contains("FK"))
                {
                    ShowAlert("⛔ 删除被拒绝：该学生已有相关成绩记录，不能直接删除！");
                }
                else
                {
                    ShowAlert(string.Format("数据库错误：{0}", ex.Message.Replace("'", "")));
                }
            }
        }

        /// <summary>
        /// 辅助：清空输入框
        /// </summary>
        private void ClearInputs()
        {
            txtStuNumber.Text = string.Empty;
            txtName.Text = string.Empty;
            txtClassId.Text = string.Empty;
            txtPhone.Text = string.Empty;
            if (ddlGender.Items.Count > 0) ddlGender.SelectedIndex = 0;
        }

        /// <summary>
        /// 辅助：查重
        /// </summary>
        private bool IsStuNumberExists(string stuNum)
        {
            string connStr = GetConnStr();
            string sql = "SELECT COUNT(1) FROM Students WHERE StuNumber = @StuNumber";
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@StuNumber", stuNum);
                    conn.Open();
                    int count = Convert.ToInt32(cmd.ExecuteScalar());
                    return count > 0;
                }
            }
        }

        /// <summary>
        /// 辅助：JS 弹窗
        /// </summary>
        private void ShowAlert(string msg)
        {
            string script = string.Format("alert('{0}');", msg);
            ClientScript.RegisterStartupScript(this.GetType(), "alert", script, true);
        }
    }
}