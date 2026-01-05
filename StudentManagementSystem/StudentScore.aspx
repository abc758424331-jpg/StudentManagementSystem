<%@ Page Language="C#" AutoEventWireup="true" CodeFile="StudentScore.aspx.cs" Inherits="StudentScore" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>我的成绩单 | 智慧教务系统</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700&family=Inter:wght@400;600&display=swap" rel="stylesheet">
    
    <script>
        // === 1. 页面加载前立即同步主题 ===
        (function () {
            const savedTheme = localStorage.getItem('theme') || 'dark';
            document.documentElement.setAttribute('data-theme', savedTheme);
        })();
    </script>

    <style>
        /* === 2. 学生版主题变量 (星云紫/靛青) === */
        :root {
            --primary: #6366f1;       /* Indigo 500 */
            --primary-hover: #4f46e5; /* Indigo 600 */
            --success: #10b981;       /* Green 500 */
            --warning: #f59e0b;       /* Amber 500 */
            --danger: #ef4444;        /* Red 500 */
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }

        /* 🌑 暗黑模式 */
        [data-theme="dark"] {
            --bg-body: #0f172a;
            --bg-card: #1e293b;
            --text-main: #f1f5f9;
            --text-sub: #94a3b8;
            --border: #334155;
            --hover-bg: rgba(255,255,255,0.05);
            --input-bg: #0f172a;
        }

        /* ☀️ 明亮模式 */
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
            transition: background-color 0.3s, color 0.3s;
        }

        form { display: flex; flex-direction: column; min-height: 100vh; }

        /* === 导航栏 === */
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

        /* === 主内容区 === */
        .main-content {
            flex: 1; padding: 40px; max-width: 1400px; margin: 0 auto; width: 100%; box-sizing: border-box;
        }
        
        .page-header { margin-bottom: 30px; display:flex; justify-content:space-between; align-items:flex-end; }
        .page-title { font-size: 24px; font-weight: 700; margin: 0; color: var(--text-main); }
        .page-subtitle { color: var(--text-sub); margin-top: 5px; font-size: 14px; }
        .btn-back {
            color: var(--text-sub); text-decoration: none; font-size: 14px; display: flex; align-items: center; gap: 6px;
            padding: 8px 16px; border-radius: 6px; border: 1px solid var(--border); transition: all 0.2s;
        }
        .btn-back:hover { background: var(--hover-bg); color: var(--text-main); border-color: var(--text-sub); }

        /* === 学期筛选与统计区 === */
        .dashboard-row {
            display: grid; grid-template-columns: 2fr 1fr 1fr; gap: 24px; margin-bottom: 30px;
        }
        
        .control-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px; padding: 24px;
            display: flex; flex-direction: column; justify-content: center;
            box-shadow: var(--shadow);
        }
        
        .filter-label { font-size: 13px; color: var(--text-sub); margin-bottom: 8px; font-weight: 600; text-transform: uppercase; }
        .form-select {
            background-color: var(--input-bg);
            border: 1px solid var(--border);
            color: var(--text-main);
            padding: 10px 14px; border-radius: 8px;
            font-family: inherit; font-size: 15px; width: 100%;
            outline: none; cursor: pointer; transition: border-color 0.2s;
        }
        .form-select:focus { border-color: var(--primary); }

        .stat-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px; padding: 20px;
            display: flex; align-items: center; justify-content: space-between;
            box-shadow: var(--shadow);
        }
        .stat-info h3 { margin: 0; font-size: 14px; color: var(--text-sub); font-weight: 500; }
        .stat-info .value { font-size: 28px; font-weight: 700; color: var(--text-main); margin-top: 5px; font-family: 'Inter', sans-serif; }
        .stat-icon-box {
            width: 48px; height: 48px; border-radius: 10px;
            display: flex; align-items: center; justify-content: center; font-size: 20px;
        }

        /* === 成绩表格 === */
        .table-section {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px; padding: 24px;
            box-shadow: var(--shadow);
        }
        .table-header { margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid var(--border); }
        .table-title { font-size: 18px; font-weight: 600; color: var(--text-main); }

        .custom-grid { width: 100%; border-collapse: collapse; color: var(--text-main); }
        .custom-grid th {
            text-align: left; padding: 14px 16px;
            color: var(--text-sub); font-size: 13px; font-weight: 600;
            border-bottom: 1px solid var(--border);
        }
        .custom-grid td { padding: 16px; border-bottom: 1px solid var(--border); font-size: 14px; vertical-align: middle; }
        .custom-grid tr:last-child td { border-bottom: none; }
        .custom-grid tr:hover { background-color: var(--hover-bg); }

        /* 分数样式 */
        .score-val { font-family: 'Inter', sans-serif; font-weight: 700; font-size: 16px; }
        .score-pass { color: var(--success); }
        .score-fail { color: var(--danger); }

        /* 状态徽章 */
        .badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 5px; }
        .badge-success { background: rgba(16, 185, 129, 0.15); color: var(--success); border: 1px solid rgba(16, 185, 129, 0.2); }
        .badge-warning { background: rgba(245, 158, 11, 0.15); color: var(--warning); border: 1px solid rgba(245, 158, 11, 0.2); }
        .badge-danger { background: rgba(239, 68, 68, 0.15); color: var(--danger); border: 1px solid rgba(239, 68, 68, 0.2); }
        .badge-info { background: rgba(99, 102, 241, 0.15); color: var(--primary); border: 1px solid rgba(99, 102, 241, 0.2); }

        /* 补考按钮 */
        .btn-retake {
            background: transparent; color: var(--danger); 
            border: 1px solid var(--danger); padding: 6px 14px; border-radius: 6px;
            font-size: 13px; font-weight: 600; text-decoration: none;
            display: inline-flex; align-items: center; gap: 5px; transition: all 0.2s;
        }
        .btn-retake:hover { background: var(--danger); color: #fff; transform: translateY(-1px); box-shadow: 0 2px 8px rgba(239, 68, 68, 0.3); }

    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="navbar">
            <div class="brand">
                <i class="fas fa-graduation-cap"></i> 智慧教务 | 学生端
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
                <div>
                    <h1 class="page-title">数字化成绩单</h1>
                    <p class="page-subtitle">查询您的历史成绩、绩点及学分获取情况</p>
                </div>
                <a href="StudentHome.aspx" class="btn-back"><i class="fas fa-arrow-left"></i> 返回主页</a>
            </div>

            <div class="dashboard-row">
                <div class="control-card">
                    <div class="filter-label"><i class="fas fa-filter"></i> 切换学期</div>
                    <asp:DropDownList ID="ddlTerm" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlTerm_SelectedIndexChanged">
                    </asp:DropDownList>
                </div>

                <div class="stat-card">
                    <div class="stat-info">
                        <h3>学期平均分</h3>
                        <div class="value"><asp:Literal ID="ltlTermAvg" runat="server" Text="0.0"></asp:Literal></div>
                    </div>
                    <div class="stat-icon-box" style="background:rgba(99, 102, 241, 0.1); color:var(--primary);">
                        <i class="fas fa-chart-bar"></i>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-info">
                        <h3>获得学分</h3>
                        <div class="value" style="color:#10b981;"><asp:Literal ID="ltlTermCredit" runat="server" Text="0"></asp:Literal></div>
                    </div>
                    <div class="stat-icon-box" style="background:rgba(16, 185, 129, 0.1); color:#10b981;">
                        <i class="fas fa-check-square"></i>
                    </div>
                </div>
            </div>

            <div class="table-section">
                <div class="table-header">
                    <div class="table-title">成绩详情明细</div>
                </div>

                <asp:GridView ID="gvScores" runat="server" CssClass="custom-grid" AutoGenerateColumns="False" 
                    OnRowCommand="gvScores_RowCommand" OnRowDataBound="gvScores_RowDataBound"
                    GridLines="None" EmptyDataText="该学期暂无成绩记录">
                    <Columns>
                        <asp:BoundField DataField="CourseName" HeaderText="课程名称" />
                        <asp:BoundField DataField="TeacherName" HeaderText="任课教师" />
                        <asp:BoundField DataField="CourseType" HeaderText="课程性质" Visible="false" /> <%-- 预留 --%>
                        <asp:BoundField DataField="Credit" HeaderText="学分" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                        
                        <%-- 分数显示 (简单着色) --%>
                        <asp:TemplateField HeaderText="成绩">
                            <ItemTemplate>
                                <span class='score-val <%# Convert.ToDouble(Eval("Score")) >= 60 ? "score-pass" : "score-fail" %>'>
                                    <%# Eval("Score") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- 状态 (调用后端方法) --%>
                        <asp:TemplateField HeaderText="状态">
                            <ItemTemplate>
                                <%# GetScoreStatusHtml(Eval("Score"), Eval("RetakeStatus")) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- 操作 (申请补考) --%>
                        <asp:TemplateField HeaderText="后续操作" ItemStyle-Width="150px" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnRetake" runat="server" CommandName="ApplyRetake" CommandArgument='<%# Eval("ScoreId") %>' 
                                    CssClass="btn-retake" Visible="false"
                                    OnClientClick="return confirm('⚠️ 确认申请该课程的补考吗？');">
                                    <i class="fas fa-redo"></i> 申请补考
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="padding:40px; text-align:center; color:var(--text-sub);">
                            <i class="fas fa-clipboard-list" style="font-size:32px; margin-bottom:10px; opacity:0.5;"></i>
                            <p>未查询到所选学期的成绩数据。</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>

        </div>
    </form>

    <script>
        // === 主题切换逻辑 ===
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

        // 初始化
        const saved = localStorage.getItem('theme') || 'dark';
        updateIcon(saved);
    </script>
</body>
</html>