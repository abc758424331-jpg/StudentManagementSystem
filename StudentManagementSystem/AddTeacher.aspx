<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AddTeacher.aspx.cs" Inherits="AddTeacher" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" data-theme="dark">
<head runat="server">
    <title>录入教师 | 智慧教务中枢</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Rajdhani:wght@500;700&display=swap" rel="stylesheet">
    
    <style>
        /* === 1. 核心主题变量 === */
        :root {
            --ease-elastic: cubic-bezier(0.68, -0.55, 0.265, 1.55);
            --ease-smooth: cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        [data-theme="dark"] {
            --bg-color: #0b1120;
            --bg-gradient: radial-gradient(circle at 50% 50%, #1e293b 0%, #0b1120 100%);
            --glass-panel: rgba(30, 41, 59, 0.75);
            --glass-border: rgba(255, 255, 255, 0.1);
            --text-main: #f8fafc;
            --text-sub: #94a3b8;
            --primary: #10b981; /* 绿色系 */
            --primary-shadow: rgba(16, 185, 129, 0.4);
            --accent: #06b6d4;
            --danger: #ef4444;
            --p-color-rgb: 16, 185, 129; 
            --l-color-rgb: 148, 163, 184;
            --input-bg: rgba(15, 23, 42, 0.6);
            --shadow-card: 0 25px 50px -12px rgba(0, 0, 0, 0.6);
        }

        [data-theme="light"] {
            --bg-color: #f1f5f9;
            --bg-gradient: linear-gradient(135deg, #e2e8f0 0%, #f8fafc 100%);
            --glass-panel: rgba(255, 255, 255, 0.85);
            --glass-border: rgba(255, 255, 255, 0.6);
            --text-main: #1e293b;
            --text-sub: #475569;
            --primary: #059669;
            --primary-shadow: rgba(5, 150, 105, 0.2);
            --accent: #0891b2;
            --danger: #dc2626;
            --p-color-rgb: 5, 150, 105;
            --l-color-rgb: 148, 163, 184;
            --input-bg: rgba(255, 255, 255, 0.8);
            --shadow-card: 0 20px 40px -10px rgba(0, 0, 0, 0.15);
        }

        body {
            margin: 0; padding: 0;
            background: var(--bg-color); background-image: var(--bg-gradient);
            color: var(--text-main); font-family: 'Inter', sans-serif;
            overflow-x: hidden; min-height: 100vh;
            transition: background 0.6s ease, color 0.6s ease;
        }

        #particle-canvas {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            z-index: -1; pointer-events: none;
        }

        .fade-in { animation: fadeIn 0.8s var(--ease-smooth) forwards; opacity: 0; transform: translateY(20px); }
        @keyframes fadeIn { to { opacity: 1; transform: translateY(0); } }

        /* === 2. 导航栏 === */
        .navbar {
            height: 70px; padding: 0 40px;
            background: var(--glass-panel);
            backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
            border-bottom: 1px solid var(--glass-border);
            display: flex; align-items: center; justify-content: space-between;
            position: fixed; top: 0; width: 100%; z-index: 1000; box-sizing: border-box;
        }

        .brand {
            font-family: 'Rajdhani', sans-serif; font-weight: 700; font-size: 24px;
            letter-spacing: 2px; color: var(--text-main);
            display: flex; align-items: center; gap: 10px; text-decoration:none;
        }
        .brand i { color: var(--primary); }

        .nav-actions { display: flex; align-items: center; gap: 20px; }

        .theme-toggle {
            width: 40px; height: 40px; border-radius: 50%;
            background: var(--glass-panel); border: 1px solid var(--glass-border);
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; color: var(--text-main); font-size: 18px;
            transition: all 0.3s var(--ease-elastic);
        }
        .theme-toggle:hover { transform: rotate(180deg) scale(1.1); color: var(--primary); border-color: var(--primary); }

        /* [修复] 用户信息卡片：添加了 lblUser */
        .user-profile {
            display: flex; align-items: center; gap: 12px;
            padding: 6px 16px; border-radius: 30px;
            background: rgba(125,125,125,0.1); border: 1px solid var(--glass-border);
        }
        .user-avatar {
            width: 32px; height: 32px; border-radius: 50%;
            background: linear-gradient(135deg, var(--primary), var(--accent));
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; color: #fff; font-size: 14px;
        }

        .btn-logout {
            background: transparent; border: 1px solid var(--danger); color: var(--danger);
            padding: 6px 16px; border-radius: 6px; cursor: pointer; transition: 0.3s;
            font-size: 12px; letter-spacing: 1px; font-weight: 600;
        }
        .btn-logout:hover { background: var(--danger); color: #fff; box-shadow: 0 0 15px rgba(239, 68, 68, 0.4); }

        .btn-back {
            background: transparent; border: 1px solid var(--glass-border); color: var(--text-sub);
            padding: 8px 20px; border-radius: 8px; cursor: pointer; transition: 0.3s;
            font-size: 13px; text-decoration: none; display: flex; align-items: center; gap: 8px;
        }
        .btn-back:hover { background: var(--glass-border); color: var(--text-main); }

        /* === 3. 录入终端 === */
        .main-container {
            display: flex; justify-content: center; align-items: center;
            min-height: calc(100vh - 70px); margin-top: 70px; padding: 20px;
        }

        .data-card {
            width: 100%; max-width: 500px;
            background: var(--glass-panel); border: 1px solid var(--glass-border);
            border-radius: 24px; padding: 45px;
            box-shadow: var(--shadow-card);
            position: relative; overflow: hidden;
            transform-style: preserve-3d; perspective: 1000px;
            animation: cardFloat 6s ease-in-out infinite;
        }
        @keyframes cardFloat { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-10px); } }

        .data-card::before {
            content: ''; position: absolute; top: 0; left: 0; width: 100%; height: 3px;
            background: linear-gradient(90deg, transparent, var(--primary), transparent);
            animation: scan 3s infinite linear; box-shadow: 0 0 10px var(--primary);
        }
        @keyframes scan { 0% { transform: translateX(-100%); } 100% { transform: translateX(100%); } }

        .card-header { text-align: center; margin-bottom: 35px; }
        .icon-box {
            width: 64px; height: 64px; margin: 0 auto 15px;
            background: rgba(255,255,255,0.05); border-radius: 16px;
            display: flex; align-items: center; justify-content: center;
            font-size: 32px; color: var(--primary);
            box-shadow: 0 0 30px var(--primary-shadow);
            border: 1px solid var(--glass-border);
        }
        .card-header h2 { margin: 0; font-family: 'Rajdhani', sans-serif; font-size: 28px; font-weight: 700; letter-spacing: 1px; }
        .card-header p { margin: 6px 0 0; color: var(--text-sub); font-size: 13px; letter-spacing: 0.5px; }

        /* === 4. 表单样式 === */
        .form-group { margin-bottom: 25px; position: relative; }
        .form-label {
            display: block; font-size: 11px; color: var(--text-sub);
            margin-bottom: 8px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px;
        }

        .cyber-input {
            width: 100%; padding: 14px 14px 14px 45px;
            background: var(--input-bg); border: 1px solid var(--glass-border);
            border-radius: 12px; color: var(--text-main); font-size: 15px;
            box-sizing: border-box; transition: all 0.3s ease;
        }
        .cyber-input:focus {
            border-color: var(--primary); outline: none;
            box-shadow: 0 0 0 4px var(--primary-shadow);
            background: rgba(255,255,255,0.08);
        }
        
        .input-icon {
            position: absolute; left: 16px; bottom: 16px;
            color: var(--text-sub); font-size: 16px; transition: 0.3s;
        }
        .cyber-input:focus + .input-icon { color: var(--primary); transform: scale(1.1); }

        .btn-submit {
            width: 100%; padding: 16px; border: none; border-radius: 12px;
            background: linear-gradient(135deg, var(--primary), var(--accent));
            color: #fff; font-size: 16px; font-weight: 700; letter-spacing: 2px;
            text-transform: uppercase; cursor: pointer; transition: 0.3s;
            box-shadow: 0 10px 20px -5px var(--primary-shadow);
            margin-top: 15px; position: relative; overflow: hidden;
        }
        .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 15px 30px -5px var(--primary-shadow); }
        .btn-submit:active { transform: scale(0.98); }

        .msg-box { min-height: 24px; text-align: center; margin-top: 25px; font-size: 13px; font-weight: 600; }
        
        .corner { position: absolute; width: 20px; height: 20px; border: 2px solid var(--glass-border); transition: 0.3s; }
        .corner-tl { top: 15px; left: 15px; border-right: none; border-bottom: none; }
        .corner-br { bottom: 15px; right: 15px; border-left: none; border-top: none; }
        .data-card:hover .corner { border-color: var(--primary); width: 30px; height: 30px; }
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
        <a href="Default.aspx" class="brand">
            <i class="fas fa-shield-alt fa-spin" style="animation-duration: 15s;"></i> UNIVERSE 
            <span style="font-weight:300; opacity:0.6; font-size:14px; margin-left:5px;">ADMIN CONSOLE</span>
        </a>
        <div class="nav-actions">
            <a href="Default.aspx" class="btn-back">
                <i class="fas fa-arrow-left"></i> Student List
            </a>
            
            <div class="user-profile">
                <div class="user-avatar"><i class="fas fa-user-shield"></i></div>
                <div>
                    <div style="font-size:13px; font-weight:600;">
                        <asp:Label ID="lblUser" runat="server"></asp:Label>
                    </div>
                    <div style="font-size:11px; opacity:0.6;">ADMIN</div>
                </div>
            </div>

            <asp:Button ID="btnLogout" runat="server" Text="LOGOUT" OnClick="btnLogout_Click" 
                CssClass="btn-logout" />
        </div>
    </div>

    <div class="main-container fade-in">
        <div class="data-card">
            <div class="corner corner-tl"></div>
            <div class="corner corner-br"></div>

            <div class="card-header">
                <div class="icon-box"><i class="fas fa-user-plus"></i></div>
                <h2>Register Faculty</h2>
                <p>Create new teacher profile in the database</p>
            </div>

            <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                <ContentTemplate>
                    
                    <div class="form-group">
                        <label class="form-label">Employee ID / 工号</label>
                        <asp:TextBox ID="txtWorkNo" runat="server" CssClass="cyber-input" placeholder="e.g. T202501"></asp:TextBox>
                        <i class="fas fa-id-card input-icon"></i>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Full Name / 姓名</label>
                        <asp:TextBox ID="txtName" runat="server" CssClass="cyber-input" placeholder="e.g. Prof. Zhang"></asp:TextBox>
                        <i class="fas fa-user input-icon"></i>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Contact / 电话 (Optional)</label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="cyber-input" placeholder="Mobile Number"></asp:TextBox>
                        <i class="fas fa-phone-alt input-icon"></i>
                    </div>

                    <asp:Button ID="btnSave" runat="server" Text="INITIALIZE PROFILE" CssClass="btn-submit" OnClick="btnSave_Click" />
                    
                    <div class="msg-box">
                        <asp:Label ID="lblMsg" runat="server"></asp:Label>
                    </div>

                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>
    </form>

    <script>
        // === 主题切换 ===
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

        // === 粒子引擎 ===
        const canvas = document.getElementById('particle-canvas');
        const ctx = canvas.getContext('2d');
        let width, height;
        let particles = [];
        let mouse = { x: null, y: null };

        function getThemeColors() {
            const style = getComputedStyle(document.documentElement);
            const pColor = style.getPropertyValue('--p-color-rgb').trim().split(',');
            const lColor = style.getPropertyValue('--l-color-rgb').trim().split(',');
            return { p: pColor, l: lColor };
        }

        function resize() {
            width = canvas.width = window.innerWidth;
            height = canvas.height = window.innerHeight;
        }

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
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
                ctx.fillStyle = `rgba(${colors.p[0]}, ${colors.p[1]}, ${colors.p[2]}, ${0.5 * this.z})`;
                ctx.fill();
            }
        }

        function initParticles() {
            particles = [];
            for (let i = 0; i < 80; i++) particles.push(new Particle());
        }

        function animate() {
            ctx.clearRect(0, 0, width, height);
            const colors = getThemeColors();
            for (let i = 0; i < particles.length; i++) {
                particles[i].update();
                particles[i].draw(colors);
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

        const card = document.querySelector('.data-card');
        document.addEventListener('mousemove', (e) => {
            const xAxis = (window.innerWidth / 2 - e.pageX) / 40;
            const yAxis = (window.innerHeight / 2 - e.pageY) / 40;
            card.style.transform = `rotateY(${xAxis}deg) rotateX(${yAxis}deg)`;
        });
    </script>
</body>
</html>