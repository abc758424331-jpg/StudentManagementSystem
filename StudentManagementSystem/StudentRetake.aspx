<%@ Page Language="C#" AutoEventWireup="true" CodeFile="StudentRetake.aspx.cs" Inherits="StudentRetake" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" data-theme="dark">
<head runat="server">
    <title>补考申请 | 智慧教务中枢</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Rajdhani:wght@500;700&display=swap" rel="stylesheet">
    
    <style>
        /* === 复用核心主题 (保持星际风格) === */
        :root { --ease-smooth: cubic-bezier(0.25, 0.46, 0.45, 0.94); }
        [data-theme="dark"] {
            --bg-color: #0b1120;
            --bg-gradient: radial-gradient(circle at 50% 50%, #1e293b 0%, #0b1120 100%);
            --glass-panel: rgba(30, 41, 59, 0.75);
            --glass-border: rgba(255, 255, 255, 0.1);
            --text-main: #f8fafc;
            --text-sub: #94a3b8;
            
            /* 补考专用配色：红色/橙色 */
            --danger: #ef4444; 
            --warning: #f59e0b;
            --success: #10b981;
            
            --table-hover: rgba(239, 68, 68, 0.05);
            --shadow-card: 0 25px 50px -12px rgba(0, 0, 0, 0.6);
            --p-color-rgb: 239, 68, 68; /* 红色粒子 */
            --l-color-rgb: 148, 163, 184;
        }

        body {
            margin: 0; padding: 0;
            background: var(--bg-color); background-image: var(--bg-gradient);
            color: var(--text-main); font-family: 'Inter', sans-serif;
            overflow-x: hidden; min-height: 100vh;
        }

        #particle-canvas { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: -1; pointer-events: none; }
        .fade-in { animation: fadeIn 0.8s var(--ease-smooth) forwards; opacity: 0; transform: translateY(20px); }
        @keyframes fadeIn { to { opacity: 1; transform: translateY(0); } }

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
        .brand i { color: var(--danger); animation: pulse 2s infinite; }
        @keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.5; } 100% { opacity: 1; } }

        .btn-back {
            background: transparent; border: 1px solid var(--glass-border); color: var(--text-sub);
            padding: 8px 20px; border-radius: 8px; cursor: pointer; transition: 0.3s;
            font-size: 13px; text-decoration: none; display: flex; align-items: center; gap: 8px;
        }
        .btn-back:hover { background: var(--glass-border); color: var(--text-main); }

        /* 主容器 */
        .main-container { max-width: 1000px; margin: 110px auto 50px; padding: 0 20px; }

        .header-panel { 
            margin-bottom: 30px; border-bottom: 1px solid var(--glass-border); padding-bottom: 20px; 
            display: flex; justify-content: space-between; align-items: flex-end;
        }
        .header-left h2 { 
            font-family: 'Rajdhani'; font-size: 32px; font-weight: 700; color: var(--danger); 
            text-transform: uppercase; margin: 0; letter-spacing: 1px;
        }
        .header-left p { color: var(--text-sub); font-size: 14px; margin-top: 5px; }
        
        .header-right { text-align: right; }
        .user-label { font-size: 12px; color: var(--text-sub); letter-spacing: 1px; }
        .user-value { font-family: 'Rajdhani'; font-weight: 700; color: var(--danger); font-size: 18px; }

        /* 表格 */
        .grid-container {
            background: var(--glass-panel); border: 1px solid var(--glass-border);
            border-radius: 16px; overflow: hidden; box-shadow: var(--shadow-card);
        }
        .cyber-grid { width: 100%; border-collapse: collapse; }
        .cyber-grid th {
            background: rgba(0,0,0,0.2); color: var(--text-sub);
            padding: 15px 20px; text-align: left; font-weight: 600; font-size: 12px;
            text-transform: uppercase; letter-spacing: 1px; border-bottom: 1px solid var(--glass-border);
        }
        .cyber-grid td {
            padding: 15px 20px; color: var(--text-main);
            border-bottom: 1px solid var(--glass-border); font-size: 14px; vertical-align: middle;
        }
        .cyber-grid tr:hover td { background: var(--table-hover); }

        /* 状态徽章 */
        .badge {
            padding: 4px 10px; border-radius: 4px; font-size: 11px; font-weight: 700; text-transform: uppercase;
            display: inline-block; letter-spacing: 0.5px;
        }
        .bg-fail { background: rgba(239, 68, 68, 0.15); color: var(--danger); border: 1px solid var(--danger); }
        .bg-pending { background: rgba(245, 158, 11, 0.15); color: var(--warning); border: 1px solid var(--warning); }
        .bg-done { background: rgba(16, 185, 129, 0.15); color: var(--success); border: 1px solid var(--success); }

        /* 申请按钮 */
        .btn-apply {
            background: linear-gradient(135deg, var(--danger), #b91c1c);
            color: white; border: none; padding: 8px 16px; border-radius: 6px;
            font-weight: 700; font-size: 12px; cursor: pointer; transition: 0.3s;
            box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
        }
        .btn-apply:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(239, 68, 68, 0.5); }
    </style>
</head>
<body>
    <button class="theme-toggle" id="btnTheme" onclick="toggleTheme()" type="button" style="position:fixed; top:85px; right:40px; z-index:900;">
        <i class="fas fa-moon" id="themeIcon"></i>
    </button>

    <canvas id="particle-canvas"></canvas>

    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

    <div class="navbar fade-in">
        <a href="StudentHome.aspx" class="brand">
            <i class="fas fa-exclamation-triangle"></i> RETAKE CENTER
        </a>
        <div class="nav-actions">
            <a href="StudentHome.aspx" class="btn-back">
                <i class="fas fa-arrow-left"></i> Dashboard
            </a>
        </div>
    </div>

    <div class="main-container fade-in">
        <div class="header-panel">
            <div class="header-left">
                <h2>重修申请</h2>
                <p>Submit applications for failed courses. Once approved, verify the schedule with your instructor.</p>
            </div>
            <div class="header-right">
                <div class="user-label">CURRENT USER</div>
                <div class="user-value">
                    <asp:Label ID="lblUser" runat="server"></asp:Label>
                </div>
            </div>
        </div>

        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <div class="grid-container">
                    <asp:GridView ID="gvRetake" runat="server" AutoGenerateColumns="False" 
                        DataKeyNames="ScoreId" CssClass="cyber-grid" GridLines="None"
                        OnRowCommand="gvRetake_RowCommand">
                        <Columns>
                            <asp:TemplateField HeaderText="COURSE INFO">
                                <ItemTemplate>
                                    <div style="font-weight:700; font-size:15px;"><%# Eval("CourseName") %></div>
                                    <div style="font-size:12px; color:var(--text-sub); margin-top:3px;">
                                        <i class="fas fa-user-tie"></i> <%# Eval("TeacherName") %>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="Term" HeaderText="TERM" ItemStyle-HorizontalAlign="Center" />
                            
                            <asp:TemplateField HeaderText="SCORE" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <span style="color:var(--danger); font-weight:700; font-size:16px; font-family:'Rajdhani'">
                                        <%# Eval("Score") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="STATUS" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <%# GetStatusBadge(Eval("RetakeStatus")) %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="ACTION" ItemStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Button ID="btnApply" runat="server" Text="APPLY NOW" 
                                        CommandName="Apply" CommandArgument='<%# Eval("ScoreId") %>'
                                        CssClass="btn-apply" 
                                        Visible='<%# Convert.ToInt32(Eval("RetakeStatus")) <= 1 %>'
                                        OnClientClick="return confirm('Confirm retake application?');" />
                                    
                                    <asp:Label ID="lblMsg" runat="server" Text="PROCESSING" 
                                        Visible='<%# Convert.ToInt32(Eval("RetakeStatus")) > 1 %>' 
                                        style="font-size:12px; color:var(--text-sub); letter-spacing:1px; font-weight:600;">
                                    </asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div style="padding:60px; text-align:center; color:var(--text-sub);">
                                <i class="fas fa-check-circle" style="font-size:40px; margin-bottom:15px; color:var(--success); opacity:0.5;"></i>
                                <p>Excellent! No failed courses detected.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
    </form>

    <script>
        // === 主题与粒子引擎 (红色系) ===
        const html = document.documentElement;
        const themeIcon = document.getElementById('themeIcon');
        const savedTheme = localStorage.getItem('theme') || 'dark';
        applyTheme(savedTheme);

        function toggleTheme() {
            const current = html.getAttribute('data-theme');
            const target = current === 'dark' ? 'light' : 'dark';
            document.body.style.transition = 'background 0.6s ease, color 0.6s ease';
            applyTheme(target);
            localStorage.setItem('theme', target);
        }

        function applyTheme(theme) {
            html.setAttribute('data-theme', theme);
            themeIcon.className = theme === 'dark' ? 'fas fa-moon' : 'fas fa-sun';
        }

        const canvas = document.getElementById('particle-canvas');
        const ctx = canvas.getContext('2d');
        let width, height, particles = [], mouse = { x: null, y: null };

        function getThemeColors() {
            const style = getComputedStyle(document.documentElement);
            const pColor = style.getPropertyValue('--p-color-rgb').trim().split(',');
            const lColor = style.getPropertyValue('--l-color-rgb').trim().split(',');
            return { p: pColor, l: lColor };
        }

        function resize() { width = canvas.width = window.innerWidth; height = canvas.height = window.innerHeight; }

        class Particle {
            constructor() {
                this.x = Math.random() * width; this.y = Math.random() * height;
                this.z = Math.random() * 1.5 + 0.5;
                this.vx = (Math.random() - 0.5) * 0.5 * this.z;
                this.vy = (Math.random() - 0.5) * 0.5 * this.z;
                this.size = Math.random() * 2 * this.z;
            }
            update() {
                this.x += this.vx; this.y += this.vy;
                if (mouse.x != null) {
                    let dx = mouse.x - this.x; let dy = mouse.y - this.y;
                    let distance = Math.sqrt(dx * dx + dy * dy);
                    if (distance < 250) {
                        const force = (250 - distance) / 250;
                        this.vx += (dx / distance) * force * 0.02 * this.z;
                        this.vy += (dy / distance) * force * 0.02 * this.z;
                    }
                }
                if (this.x < 0 || this.x > width) this.vx *= -1;
                if (this.y < 0 || this.y > height) this.vy *= -1;
            }
            draw(colors) {
                ctx.beginPath(); ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
                ctx.fillStyle = `rgba(${colors.p[0]}, ${colors.p[1]}, ${colors.p[2]}, ${0.5 * this.z})`; ctx.fill();
            }
        }

        function initParticles() { particles = []; for (let i = 0; i < 60; i++) particles.push(new Particle()); }

        function animate() {
            ctx.clearRect(0, 0, width, height); const colors = getThemeColors();
            for (let i = 0; i < particles.length; i++) {
                particles[i].update(); particles[i].draw(colors);
                for (let j = i + 1; j < particles.length; j++) {
                    let dx = particles[i].x - particles[j].x; let dy = particles[i].y - particles[j].y;
                    let distance = Math.sqrt(dx * dx + dy * dy);
                    if (distance < 100) {
                        ctx.beginPath();
                        let opacity = (1 - distance / 100) * 0.4 * particles[i].z;
                        ctx.strokeStyle = `rgba(${colors.l[0]}, ${colors.l[1]}, ${colors.l[2]}, ${opacity})`;
                        ctx.lineWidth = 0.5 * particles[i].z;
                        ctx.moveTo(particles[i].x, particles[i].y); ctx.lineTo(particles[j].x, particles[j].y); ctx.stroke();
                    }
                }
            }
            requestAnimationFrame(animate);
        }

        window.addEventListener('resize', () => { resize(); initParticles(); });
        window.addEventListener('mousemove', (e) => { mouse.x = e.x; mouse.y = e.y; });
        window.addEventListener('mouseout', () => { mouse.x = null; mouse.y = null; });
        resize(); initParticles(); animate();
    </script>
</body>
</html>