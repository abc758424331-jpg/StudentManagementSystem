<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RetakeManage.aspx.cs" Inherits="RetakeManage" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" data-theme="dark">
<head runat="server">
    <title>补考审批 | 智慧教务中枢</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Rajdhani:wght@500;700&display=swap" rel="stylesheet">
    
    <style>
        /* === 核心主题变量 (与 TeacherHome 保持一致) === */
        :root { --ease-smooth: cubic-bezier(0.25, 0.46, 0.45, 0.94); }
        [data-theme="dark"] {
            --bg-color: #0b1120;
            --bg-gradient: radial-gradient(circle at 50% 50%, #1e293b 0%, #0b1120 100%);
            --glass-panel: rgba(30, 41, 59, 0.75);
            --glass-border: rgba(255, 255, 255, 0.1);
            --text-main: #f8fafc;
            --text-sub: #94a3b8;
            --primary: #f59e0b; /* 审批主色：橙色 */
            --primary-shadow: rgba(245, 158, 11, 0.4);
            --success: #10b981;
            --danger: #ef4444;
            --table-hover: rgba(245, 158, 11, 0.05);
        }

        body {
            margin: 0; padding: 0;
            background: var(--bg-color); background-image: var(--bg-gradient);
            color: var(--text-main); font-family: 'Inter', sans-serif;
            overflow-x: hidden; min-height: 100vh;
        }

        #particle-canvas { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: -1; pointer-events: none; }

        /* 导航栏 */
        .navbar {
            height: 70px; padding: 0 40px;
            background: var(--glass-panel); backdrop-filter: blur(20px);
            border-bottom: 1px solid var(--glass-border);
            display: flex; align-items: center; justify-content: space-between;
            position: fixed; top: 0; width: 100%; z-index: 1000; box-sizing: border-box;
        }
        .brand {
            font-family: 'Rajdhani', sans-serif; font-weight: 700; font-size: 24px;
            letter-spacing: 2px; color: var(--text-main); text-decoration:none;
            display: flex; align-items: center; gap: 10px;
        }
        .btn-back {
            background: transparent; border: 1px solid var(--glass-border); color: var(--text-sub);
            padding: 8px 20px; border-radius: 8px; cursor: pointer; transition: 0.3s;
            font-size: 13px; text-decoration: none; display: flex; align-items: center; gap: 8px;
        }
        .btn-back:hover { background: var(--glass-border); color: var(--text-main); }

        /* 主容器 */
        .main-container { max-width: 1200px; margin: 100px auto 50px; padding: 0 20px; }

        /* HUD 仪表盘 */
        .dashboard-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px; }
        .hud-card {
            background: var(--glass-panel); border: 1px solid var(--glass-border);
            border-radius: 16px; padding: 20px; display: flex; align-items: center; gap: 20px;
        }
        .hud-icon {
            width: 50px; height: 50px; border-radius: 12px; background: rgba(255,255,255,0.05);
            display: flex; align-items: center; justify-content: center; font-size: 24px; color: var(--text-sub);
        }
        .hud-info h4 { margin: 0; font-size: 12px; color: var(--text-sub); text-transform: uppercase; letter-spacing: 1px; }
        .hud-info .value { font-family: 'Rajdhani'; font-size: 32px; font-weight: 700; color: var(--text-main); }

        /* 筛选工具栏 */
        .toolbar {
            background: var(--glass-panel); border: 1px solid var(--glass-border);
            border-radius: 16px; padding: 15px 25px; margin-bottom: 20px;
            display: flex; gap: 15px; align-items: center;
        }
        .cyber-select {
            background: rgba(0,0,0,0.2); border: 1px solid var(--glass-border); color: var(--text-main);
            padding: 8px 15px; border-radius: 6px; outline: none; cursor: pointer; min-width: 150px;
        }
        .cyber-select option { background: #1e293b; color: #fff; }

        /* 赛博表格 */
        .grid-container {
            background: var(--glass-panel); border: 1px solid var(--glass-border);
            border-radius: 16px; overflow: hidden; min-height: 400px;
        }
        .cyber-grid { width: 100%; border-collapse: collapse; }
        .cyber-grid th {
            background: rgba(0,0,0,0.2); color: var(--text-sub); padding: 18px 25px; text-align: left;
            font-size: 12px; text-transform: uppercase; border-bottom: 1px solid var(--glass-border);
        }
        .cyber-grid td {
            padding: 15px 25px; color: var(--text-main); border-bottom: 1px solid var(--glass-border);
            font-size: 14px; vertical-align: middle;
        }
        .cyber-grid tr:hover td { background: var(--table-hover); }

        /* 状态标签 */
        .badge { padding: 4px 10px; border-radius: 4px; font-size: 11px; font-weight: 700; text-transform: uppercase; display: inline-block; letter-spacing: 0.5px; }
        
        /* 按钮 */
        .btn-approve {
            background: rgba(16, 185, 129, 0.1); color: var(--success); border: 1px solid var(--success);
            padding: 6px 15px; border-radius: 6px; cursor: pointer; font-size: 12px; font-weight: 700; transition: 0.3s;
        }
        .btn-approve:hover { background: var(--success); color: #fff; box-shadow: 0 0 15px rgba(16, 185, 129, 0.4); }
        
        .btn-batch {
            background: var(--primary); color: #fff; border: none; padding: 10px 25px;
            border-radius: 6px; font-weight: 600; cursor: pointer; margin-left: auto;
            box-shadow: 0 4px 15px var(--primary-shadow);
        }
        .btn-batch:hover { background: #d97706; transform: translateY(-2px); }
    </style>
</head>
<body>
    <canvas id="particle-canvas"></canvas>

    <form id="form1" runat="server">
    <div class="navbar">
        <a href="TeacherHome.aspx" class="brand">
            <i class="fas fa-tasks"></i> RETAKE OPS
        </a>
        <div style="display:flex; align-items:center; gap:15px;">
            <a href="TeacherHome.aspx" class="btn-back"><i class="fas fa-arrow-left"></i> Dashboard</a>
            <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn-back" style="border-color:var(--danger); color:var(--danger);">
                <i class="fas fa-power-off"></i> LOGOUT
            </asp:LinkButton>
        </div>
    </div>

    <div class="main-container">
        <div class="dashboard-grid">
            <div class="hud-card">
                <div class="hud-icon"><i class="fas fa-inbox"></i></div>
                <div class="hud-info"><h4>Total Applications</h4><asp:Literal ID="ltlTotal" runat="server">0</asp:Literal></div>
            </div>
            <div class="hud-card">
                <div class="hud-icon" style="color:var(--primary);"><i class="fas fa-clock"></i></div>
                <div class="hud-info"><h4>Pending Approval</h4><asp:Literal ID="ltlPending" runat="server">0</asp:Literal></div>
            </div>
            <div class="hud-card">
                <div class="hud-icon" style="color:var(--success);"><i class="fas fa-check-circle"></i></div>
                <div class="hud-info"><h4>Processed Today</h4><asp:Literal ID="ltlApproved" runat="server">0</asp:Literal></div>
            </div>
        </div>

        <div class="toolbar">
            <i class="fas fa-filter" style="color:var(--text-sub);"></i>
            <asp:DropDownList ID="ddlTerm" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlTerm_SelectedIndexChanged" CssClass="cyber-select"></asp:DropDownList>
            <asp:DropDownList ID="ddlCourse" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlCourse_SelectedIndexChanged" CssClass="cyber-select"></asp:DropDownList>
            
            <asp:Button ID="btnBatchApprove" runat="server" Text="BATCH APPROVE SELECTED" OnClick="btnBatchApprove_Click" CssClass="btn-batch" />
        </div>

        <div class="grid-container">
            <asp:GridView ID="gvApplyList" runat="server" AutoGenerateColumns="False" DataKeyNames="ScoreId"
                CssClass="cyber-grid" GridLines="None" OnRowCommand="gvApplyList_RowCommand">
                <Columns>
                    <asp:TemplateField ItemStyle-Width="40px">
                        <HeaderTemplate><asp:CheckBox ID="chkAll" runat="server" AutoPostBack="true" OnCheckedChanged="chkAll_CheckedChanged" /></HeaderTemplate>
                        <ItemTemplate>
                            <asp:CheckBox ID="chkSelect" runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="StuNumber" HeaderText="ID" />
                    <asp:BoundField DataField="Name" HeaderText="STUDENT" ItemStyle-Font-Bold="true" />
                    <asp:BoundField DataField="ClassName" HeaderText="CLASS" />
                    <asp:BoundField DataField="CourseName" HeaderText="COURSE" />
                    
                    <asp:TemplateField HeaderText="SCORE">
                        <ItemTemplate>
                            <span style="color:var(--danger); font-weight:700; font-family:'Rajdhani'; font-size:16px;">
                                <%# Eval("Score") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="STATUS" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <%# GetStatusHtml(Eval("RetakeStatus")) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="ACTION" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Button ID="btnApprove" runat="server" Text="APPROVE" 
                                CommandName="Approve" CommandArgument='<%# Eval("ScoreId") %>'
                                CssClass="btn-approve" 
                                OnClientClick="return confirm('Approve this retake application?');" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div style="padding:80px; text-align:center; color:var(--text-sub);">
                        <i class="fas fa-check-double" style="font-size:48px; margin-bottom:20px; color:var(--success); opacity:0.5;"></i>
                        <p style="font-size:16px;">All clear! No pending approvals found.</p>
                    </div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
    </form>

    <script>
        // === 粒子特效 (复用) ===
        const canvas = document.getElementById('particle-canvas');
        const ctx = canvas.getContext('2d');
        let width, height, particles = [];

        function resize() { width = canvas.width = window.innerWidth; height = canvas.height = window.innerHeight; }
        class Particle {
            constructor() { this.x = Math.random() * width; this.y = Math.random() * height; this.vx = (Math.random() - .5) * 0.5; this.vy = (Math.random() - .5) * 0.5; this.size = Math.random() * 2; }
            update() { this.x += this.vx; this.y += this.vy; if (this.x < 0 || this.x > width) this.vx *= -1; if (this.y < 0 || this.y > height) this.vy *= -1; }
            draw() { ctx.beginPath(); ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2); ctx.fillStyle = 'rgba(245, 158, 11, 0.3)'; ctx.fill(); }
        }
        function init() { particles = []; for (let i = 0; i < 60; i++) particles.push(new Particle()); }
        function animate() { ctx.clearRect(0, 0, width, height); particles.forEach(p => { p.update(); p.draw(); }); requestAnimationFrame(animate); }

        window.addEventListener('resize', () => { resize(); init(); }); resize(); init(); animate();
    </script>
</body>
</html>