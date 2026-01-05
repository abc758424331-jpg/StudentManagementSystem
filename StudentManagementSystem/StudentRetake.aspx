<%@ Page Language="C#" AutoEventWireup="true" CodeFile="StudentRetake.aspx.cs" Inherits="StudentRetake" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>补考/重修中心 | 智慧教务系统</title>
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
        /* === 2. 页面样式 (继承学生端星云紫主题) === */
        :root {
            --primary: #6366f1;       /* Indigo 500 */
            --primary-hover: #4f46e5;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --gray: #64748b;
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }

        [data-theme="dark"] {
            --bg-body: #0f172a;
            --bg-card: #1e293b;
            --text-main: #f1f5f9;
            --text-sub: #94a3b8;
            --border: #334155;
            --hover-bg: rgba(255,255,255,0.05);
            --badge-gray-bg: rgba(148, 163, 184, 0.15);
            --badge-gray-text: #94a3b8;
        }

        [data-theme="light"] {
            --bg-body: #f1f5f9;
            --bg-card: #ffffff;
            --text-main: #1e293b;
            --text-sub: #64748b;
            --border: #e2e8f0;
            --hover-bg: #f8fafc;
            --badge-gray-bg: #f1f5f9;
            --badge-gray-text: #64748b;
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

        /* 提示卡片 */
        .alert-card {
            background: rgba(99, 102, 241, 0.1); border: 1px solid rgba(99, 102, 241, 0.2);
            color: var(--text-main); padding: 16px; border-radius: 8px; margin-bottom: 30px;
            display: flex; align-items: flex-start; gap: 12px; font-size: 14px; line-height: 1.5;
        }
        .alert-icon { color: var(--primary); font-size: 18px; margin-top: 2px; }

        /* 表格区域 */
        .table-section {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px; padding: 24px;
            box-shadow: var(--shadow);
        }
        .table-header { margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid var(--border); }
        .table-title { font-size: 18px; font-weight: 600; color: var(--text-main); display: flex; align-items: center; gap: 10px; }

        .custom-grid { width: 100%; border-collapse: collapse; color: var(--text-main); }
        .custom-grid th {
            text-align: left; padding: 14px 16px;
            color: var(--text-sub); font-size: 13px; font-weight: 600;
            border-bottom: 1px solid var(--border);
        }
        .custom-grid td { padding: 16px; border-bottom: 1px solid var(--border); font-size: 14px; vertical-align: middle; }
        .custom-grid tr:last-child td { border-bottom: none; }
        .custom-grid tr:hover { background-color: var(--hover-bg); }

        /* 状态徽章 */
        .badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 5px; }
        .badge-warning { background: rgba(245, 158, 11, 0.15); color: var(--warning); border: 1px solid rgba(245, 158, 11, 0.2); }
        .badge-success { background: rgba(16, 185, 129, 0.15); color: var(--success); border: 1px solid rgba(16, 185, 129, 0.2); }
        .badge-danger { background: rgba(239, 68, 68, 0.15); color: var(--danger); border: 1px solid rgba(239, 68, 68, 0.2); }
        .badge-secondary { background: var(--badge-gray-bg); color: var(--badge-gray-text); border: 1px solid var(--border); }
        .badge-gray { background: var(--badge-gray-bg); color: var(--badge-gray-text); }

        /* 撤销按钮 */
        .btn-cancel {
            background: transparent; color: var(--text-sub); 
            border: 1px solid var(--border); padding: 6px 14px; border-radius: 6px;
            font-size: 13px; font-weight: 500; text-decoration: none;
            display: inline-flex; align-items: center; gap: 5px; transition: all 0.2s;
        }
        .btn-cancel:hover { border-color: var(--danger); color: var(--danger); }

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
                <div style="font-size:14px; color:var(--text-sub); margin-right:10px;">
                    <i class="fas fa-user-circle"></i> 我的状态
                </div>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn-logout">
                    <i class="fas fa-sign-out-alt"></i> 退出
                </asp:LinkButton>
            </div>
        </nav>

        <div class="main-content">
            
            <div class="page-header">
                <div>
                    <h1 class="page-title">补考/重修服务</h1>
                    <p class="page-subtitle">查看挂科课程详情及补考申请进度</p>
                </div>
                <a href="StudentHome.aspx" class="btn-back"><i class="fas fa-arrow-left"></i> 返回主页</a>
            </div>

            <div class="alert-card">
                <i class="fas fa-info-circle alert-icon"></i>
                <div>
                    <strong>申请规则说明：</strong><br/>
                    1. 仅限 <span style="color:var(--danger)">不及格 (< 60分)</span> 的课程提交补考或重修申请。<br/>
                    2. 在教师审批通过之前，您可以随时撤回申请；一旦审批通过，请留意考试安排。<br/>
                    3. 若显示“未申请”，请尽快前往【成绩查询】页面提交申请，以免错过截止日期。
                </div>
            </div>

            <div class="table-section">
                <div class="table-header">
                    <div class="table-title">申请进度追踪</div>
                </div>

                <asp:GridView ID="gvRetake" runat="server" CssClass="custom-grid" AutoGenerateColumns="False" 
                    OnRowCommand="gvRetake_RowCommand" OnRowDataBound="gvRetake_RowDataBound"
                    GridLines="None" EmptyDataText="👏 恭喜！当前没有挂科或补考记录。">
                    <Columns>
                        <asp:BoundField DataField="CourseName" HeaderText="课程名称" />
                        <asp:BoundField DataField="TeacherName" HeaderText="任课教师" />
                        <asp:BoundField DataField="Credit" HeaderText="学分" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                        
                        <%-- 原成绩 (处理负分) --%>
                        <asp:TemplateField HeaderText="原成绩" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <span style="font-weight:600; color:var(--danger)">
                                    <%# FormatScore(Eval("Score")) %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- 状态 (HTML徽章) --%>
                        <asp:TemplateField HeaderText="当前状态">
                            <ItemTemplate>
                                <%# GetStatusHtml(Eval("RetakeStatus")) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- 操作 (撤销) --%>
                        <asp:TemplateField HeaderText="操作" ItemStyle-Width="120px" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <%-- btnCancel 的可见性由 RowDataBound 在后端控制 (仅 Status=2 显示) --%>
                                <asp:LinkButton ID="btnCancel" runat="server" CommandName="CancelApply" CommandArgument='<%# Eval("ScoreId") %>' 
                                    CssClass="btn-cancel"
                                    OnClientClick="return confirm('⚠️ 确定要撤回这条补考申请吗？\n撤回后需要重新提交才能参加考试。');">
                                    <i class="fas fa-undo"></i> 撤销申请
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="padding:40px; text-align:center; color:var(--text-sub);">
                            <i class="fas fa-check-circle" style="font-size:32px; margin-bottom:10px; opacity:0.5; color:var(--success)"></i>
                            <p>非常棒！您当前没有需要补考或重修的课程。</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </form>

    <script>
        // === 主题切换 ===
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

        const saved = localStorage.getItem('theme') || 'dark';
        updateIcon(saved);
    </script>
</body>
</html>