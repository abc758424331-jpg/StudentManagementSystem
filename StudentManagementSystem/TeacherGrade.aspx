<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TeacherGrade.aspx.cs" Inherits="TeacherGrade" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>成绩录入控制台 | 智慧教务系统</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700&family=Inter:wght@400;600&display=swap" rel="stylesheet">
    
    <script>
        // === 1. 主题同步脚本 ===
        (function () {
            const savedTheme = localStorage.getItem('theme') || 'dark';
            document.documentElement.setAttribute('data-theme', savedTheme);
        })();
    </script>

    <style>
        /* === 2. 教师版主题 (天际蓝) === */
        :root {
            --primary: #0ea5e9;       /* Sky Blue */
            --primary-hover: #0284c7;
            --success: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }

        [data-theme="dark"] {
            --bg-body: #0f172a;
            --bg-card: #1e293b;
            --text-main: #f1f5f9;
            --text-sub: #94a3b8;
            --border: #334155;
            --hover-bg: rgba(255,255,255,0.05);
            --input-bg: #0f172a;
        }

        [data-theme="light"] {
            --bg-body: #f1f5f9;
            --bg-card: #ffffff;
            --text-main: #1e293b;
            --text-sub: #64748b;
            --border: #e2e8f0;
            --hover-bg: #f8fafc;
            --input-bg: #f8fafc;
        }

        body {
            margin: 0; padding: 0;
            background-color: var(--bg-body);
            color: var(--text-main);
            font-family: 'Noto Sans SC', 'Inter', sans-serif;
            transition: background-color 0.3s;
        }

        form { display: flex; flex-direction: column; min-height: 100vh; }

        /* 导航栏 */
        .navbar {
            background-color: var(--bg-card);
            border-bottom: 1px solid var(--border);
            padding: 0 40px; height: 64px;
            display: flex; justify-content: space-between; align-items: center;
            position: sticky; top: 0; z-index: 100;
            box-shadow: var(--shadow);
        }
        .brand { font-size: 20px; font-weight: 700; color: var(--primary); display: flex; align-items: center; gap: 10px; }
        .nav-right { display: flex; align-items: center; gap: 20px; }
        .theme-toggle-btn { background: none; border: none; cursor: pointer; color: var(--text-sub); font-size: 18px; padding: 8px; border-radius: 50%; transition: all 0.2s; }
        .theme-toggle-btn:hover { background-color: var(--hover-bg); color: var(--text-main); }
        .btn-logout { color: #ef4444; text-decoration: none; font-weight: 600; display: flex; align-items: center; gap: 6px; }

        /* 主内容区 */
        .main-content {
            flex: 1; padding: 40px; max-width: 1200px; margin: 0 auto; width: 100%; box-sizing: border-box;
        }

        .page-header { margin-bottom: 30px; display:flex; justify-content:space-between; align-items:center; }
        .page-title { font-size: 24px; font-weight: 700; margin: 0; color: var(--text-main); }
        .btn-back {
            color: var(--text-sub); text-decoration: none; font-size: 14px; display: flex; align-items: center; gap: 6px;
            padding: 8px 16px; border-radius: 6px; border: 1px solid var(--border); transition: all 0.2s;
        }
        .btn-back:hover { background: var(--hover-bg); color: var(--text-main); border-color: var(--text-sub); }

        /* 课程信息卡片 (锚点) */
        .course-info-card {
            background: linear-gradient(135deg, var(--bg-card) 0%, rgba(14, 165, 233, 0.05) 100%);
            border: 1px solid var(--border); border-left: 4px solid var(--primary);
            border-radius: 12px; padding: 24px; margin-bottom: 30px;
            display: flex; justify-content: space-between; align-items: center;
            box-shadow: var(--shadow);
        }
        .info-item h3 { margin: 0 0 5px 0; font-size: 14px; color: var(--text-sub); font-weight: 500; }
        .info-item .value { font-size: 20px; font-weight: 700; color: var(--text-main); }
        .info-icon { font-size: 32px; color: var(--primary); opacity: 0.2; }

        /* 表格区域 */
        .table-section {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px; padding: 24px;
            box-shadow: var(--shadow);
            margin-bottom: 80px; /* 为底部保存栏留出空间 */
        }
        .table-header { margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid var(--border); }
        .table-title { font-size: 18px; font-weight: 600; color: var(--text-main); }

        .custom-grid { width: 100%; border-collapse: collapse; color: var(--text-main); }
        .custom-grid th {
            text-align: left; padding: 14px 16px;
            color: var(--text-sub); font-size: 13px; font-weight: 600;
            border-bottom: 1px solid var(--border);
        }
        .custom-grid td { padding: 12px 16px; border-bottom: 1px solid var(--border); font-size: 14px; vertical-align: middle; }
        .custom-grid tr:hover { background-color: var(--hover-bg); }

        /* 输入框样式优化 */
        .grade-input {
            background-color: var(--input-bg);
            border: 1px solid var(--border);
            color: var(--text-main);
            padding: 10px; border-radius: 6px;
            width: 100px; font-family: 'Inter', sans-serif; font-weight: 600; font-size: 15px;
            transition: all 0.2s; outline: none;
        }
        .grade-input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(14, 165, 233, 0.2); }
        
        /* 实时反馈颜色 */
        .grade-input.score-pass { color: var(--success); border-color: rgba(16, 185, 129, 0.3); }
        .grade-input.score-fail { color: var(--danger); border-color: rgba(239, 68, 68, 0.3); background: rgba(239, 68, 68, 0.05); }

        /* 底部悬浮保存栏 */
        .bottom-bar {
            position: fixed; bottom: 0; left: 0; right: 0;
            background: var(--bg-card); border-top: 1px solid var(--border);
            padding: 15px 40px;
            display: flex; justify-content: flex-end; align-items: center; gap: 20px;
            box-shadow: 0 -4px 20px rgba(0,0,0,0.1); z-index: 999;
        }
        .btn-save {
            background: linear-gradient(135deg, var(--primary) 0%, #0284c7 100%);
            color: white; border: none; padding: 12px 30px; border-radius: 8px;
            font-size: 15px; font-weight: 600; cursor: pointer;
            display: inline-flex; align-items: center; gap: 8px;
            box-shadow: 0 4px 15px rgba(14, 165, 233, 0.3);
            transition: transform 0.2s;
        }
        .btn-save:hover { transform: translateY(-2px); }

    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="navbar">
            <div class="brand">
                <i class="fas fa-edit"></i> 成绩录入控制台
            </div>
            
            <div class="nav-right">
                <button type="button" class="theme-toggle-btn" onclick="toggleTheme()" title="切换主题">
                    <i class="fas fa-adjust" id="themeIcon"></i>
                </button>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn-logout">
                    <i class="fas fa-sign-out-alt"></i> 退出
                </asp:LinkButton>
            </div>
        </nav>

        <div class="main-content">
            
            <div class="page-header">
                <h1 class="page-title">录入/修改成绩</h1>
                <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="btn-back">
                    <i class="fas fa-arrow-left"></i> 返回列表
                </asp:LinkButton>
            </div>

            <div class="course-info-card">
                <div class="info-item">
                    <h3>正在录入课程</h3>
                    <div class="value"><asp:Label ID="lblCourseName" runat="server" Text="--"></asp:Label></div>
                </div>
                <div class="info-item">
                    <h3>所属学期</h3>
                    <div class="value"><asp:Label ID="lblTerm" runat="server" Text="--"></asp:Label></div>
                </div>
                <div class="info-icon">
                    <i class="fas fa-book-reader"></i>
                </div>
            </div>

            <div class="table-section">
                <div class="table-header">
                    <div class="table-title">学生名单与成绩表</div>
                    <div style="font-size:13px; color:var(--text-sub);">
                        <i class="fas fa-info-circle"></i> 提示：支持 Tab 键快速切换输入框；不及格分数将自动标红。
                    </div>
                </div>

                <asp:GridView ID="gvStudents" runat="server" CssClass="custom-grid" AutoGenerateColumns="False" 
                    GridLines="None" EmptyDataText="该课程暂无学生选修。">
                    <Columns>
                        <asp:BoundField DataField="StuNumber" HeaderText="学号" ItemStyle-Width="20%" />
                        
                        <asp:TemplateField HeaderText="姓名" ItemStyle-Width="20%">
                            <ItemTemplate>
                                <%-- 绑定 Label 用于后端报错时识别姓名 --%>
                                <asp:Label ID="lblName" runat="server" Text='<%# Eval("Name") %>' style="font-weight:500;"></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="成绩录入">
                            <ItemTemplate>
                                <asp:HiddenField ID="hfScoreId" runat="server" Value='<%# Eval("ScoreId") %>' />
                                
                                <%-- 
                                    逻辑自查: 
                                    1. type="number": 限制只能输入数字
                                    2. min/max: 前端基础拦截
                                    3. oninput: 触发JS变色逻辑
                                --%>
                                <asp:TextBox ID="txtScore" runat="server" Text='<%# Eval("Score") %>' 
                                    CssClass="grade-input" type="number" step="0.5" min="0" max="100"
                                    oninput="validateScore(this)" placeholder="0-100"></asp:TextBox>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="状态预览">
                            <ItemTemplate>
                                <%-- 占位符，由JS动态填充文字 --%>
                                <span class="status-preview" style="font-size:12px; font-weight:600;">--</span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="padding:40px; text-align:center; color:var(--text-sub);">
                            <i class="fas fa-users-slash" style="font-size:32px; margin-bottom:10px; opacity:0.5;"></i>
                            <p>暂时没有学生选修这门课程。</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <div class="bottom-bar">
            <div style="margin-right:auto; color:var(--text-sub); font-size:13px;">
                <i class="fas fa-check-circle" style="color:var(--success)"></i> 系统已准备就绪
            </div>
            <asp:Button ID="btnSave" runat="server" Text="保存所有更改" OnClick="btnSave_Click" CssClass="btn-save" />
        </div>
    </form>

    <script>
        // === 1. 分数验证与变色逻辑 ===
        function validateScore(input) {
            const val = parseFloat(input.value);
            const row = input.closest('tr');
            const statusSpan = row.querySelector('.status-preview');

            // 移除旧类
            input.classList.remove('score-pass', 'score-fail');

            if (isNaN(val)) {
                // 空值
                if (statusSpan) { statusSpan.textContent = "待录入"; statusSpan.style.color = "var(--text-sub)"; }
                return;
            }

            // 范围提示
            if (val < 0 || val > 100) {
                input.style.borderColor = "var(--danger)";
                if (statusSpan) { statusSpan.textContent = "❌ 无效数值"; statusSpan.style.color = "var(--danger)"; }
                return;
            }

            // 及格判定
            if (val >= 60) {
                input.classList.add('score-pass');
                if (statusSpan) { statusSpan.textContent = "✅ 及格"; statusSpan.style.color = "var(--success)"; }
            } else {
                input.classList.add('score-fail');
                if (statusSpan) { statusSpan.textContent = "⚠️ 不及格"; statusSpan.style.color = "var(--danger)"; }
            }
        }

        // === 2. 页面加载时初始化颜色 ===
        window.onload = function () {
            const inputs = document.querySelectorAll('.grade-input');
            inputs.forEach(input => validateScore(input));

            // 初始化主题
            const saved = localStorage.getItem('theme') || 'dark';
            updateIcon(saved);
        };

        // === 3. 主题切换 ===
        function toggleTheme() {
            const current = document.documentElement.getAttribute('data-theme');
            const target = current === 'dark' ? 'light' : 'dark';
            document.documentElement.setAttribute('data-theme', target);
            localStorage.setItem('theme', target);
            updateIcon(target);
        }

        function updateIcon(theme) {
            const icon = document.getElementById('themeIcon');
            if (icon) icon.className = theme === 'dark' ? 'fas fa-moon' : 'fas fa-sun';
        }
    </script>
</body>
</html>