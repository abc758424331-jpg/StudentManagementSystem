<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" data-theme="dark">
<head runat="server">
    <title>用户登录 | 智慧教务中枢</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Rajdhani:wght@500;700&display=swap" rel="stylesheet">
    
    <style>
        /* === 1. 核心 CSS 变量系统 === */
        :root {
            --ease-elastic: cubic-bezier(0.68, -0.55, 0.265, 1.55);
            --ease-smooth: cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        /* 🌑 暗黑模式 (深空科技) */
        [data-theme="dark"] {
            --bg-color: #0b1120; /* 更深的蓝黑 */
            --bg-gradient: radial-gradient(circle at 50% 50%, #1e293b 0%, #0b1120 100%);
            --glass-panel: rgba(30, 41, 59, 0.7);
            --glass-border: rgba(255, 255, 255, 0.1);
            --primary: #3b82f6;
            --primary-glow: rgba(59, 130, 246, 0.5);
            --text-main: #f8fafc;
            --text-sub: #94a3b8;
        }

        /* ☀️ 明亮模式 (极简白) - 保留以备切换 */
        [data-theme="light"] {
            --bg-color: #f8fafc;
            --bg-gradient: linear-gradient(135deg, #e2e8f0 0%, #f8fafc 100%);
            --glass-panel: rgba(255, 255, 255, 0.85);
            --glass-border: rgba(0, 0, 0, 0.05);
            --primary: #2563eb;
            --primary-glow: rgba(37, 99, 235, 0.3);
            --text-main: #1e293b;
            --text-sub: #64748b;
        }

        body {
            margin: 0; padding: 0;
            background: var(--bg-color);
            background-image: var(--bg-gradient);
            font-family: "Microsoft YaHei", "PingFang SC", 'Inter', sans-serif; /* 优先中文字体 */
            height: 100vh;
            display: flex; justify-content: center; align-items: center;
            overflow: hidden; transition: background 0.5s ease;
        }

        /* === 2. 登录卡片容器 (玻璃拟态) === */
        .login-card {
            width: 400px;
            padding: 40px;
            background: var(--glass-panel);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid var(--glass-border);
            border-radius: 24px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            z-index: 10;
            animation: cardEntrance 0.8s var(--ease-elastic);
        }

        @keyframes cardEntrance {
            0% { transform: translateY(50px) scale(0.9); opacity: 0; }
            100% { transform: translateY(0) scale(1); opacity: 1; }
        }

        /* 标题区 */
        .header { text-align: center; margin-bottom: 35px; }
        .logo-icon {
            font-size: 48px; color: var(--primary);
            filter: drop-shadow(0 0 15px var(--primary-glow));
            margin-bottom: 15px; display: inline-block;
        }
        .title {
            font-family: "Microsoft YaHei", 'Rajdhani', sans-serif;
            font-weight: 700; font-size: 28px; color: var(--text-main); margin: 0;
            letter-spacing: 1px;
        }
        .subtitle { color: var(--text-sub); font-size: 14px; margin-top: 5px; }

        /* === 3. 身份选择滑块 (核心交互) === */
        .role-switcher {
            display: flex; justify-content: space-between;
            background: rgba(0,0,0,0.2); border-radius: 12px;
            padding: 5px; margin-bottom: 30px; position: relative;
        }
        .glider {
            position: absolute; top: 5px; left: 5px; height: 36px; width: 32%;
            background: var(--primary); border-radius: 8px;
            transition: transform 0.3s var(--ease-smooth); z-index: 1;
            box-shadow: 0 4px 12px var(--primary-glow);
        }
        .role-item {
            flex: 1; text-align: center; padding: 8px 0;
            font-size: 14px; font-weight: 600; color: var(--text-sub);
            cursor: pointer; z-index: 2; transition: color 0.3s;
            position: relative;
        }
        .role-item.active { color: #fff; }
        
        /* 隐藏 Radio */
        .role-radio { display: none; }

        /* === 4. 输入框组 === */
        .input-group { position: relative; margin-bottom: 20px; }
        .input-icon {
            position: absolute; left: 15px; top: 50%; transform: translateY(-50%);
            color: var(--text-sub); transition: color 0.3s;
        }
        .form-control {
            width: 100%; padding: 14px 14px 14px 45px;
            background: rgba(255,255,255,0.05); border: 1px solid var(--glass-border);
            border-radius: 12px; color: var(--text-main); font-size: 15px;
            transition: all 0.3s; box-sizing: border-box; /* 修复宽度溢出 */
        }
        .form-control:focus {
            background: rgba(255,255,255,0.1); border-color: var(--primary);
            outline: none; box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
        }
        .form-control:focus + .input-icon { color: var(--primary); }

        /* === 5. 登录按钮 (流光特效) === */
        .btn-login {
            width: 100%; padding: 14px;
            background: linear-gradient(135deg, var(--primary) 0%, #2563eb 100%);
            border: none; border-radius: 12px;
            color: white; font-weight: 600; font-size: 16px; letter-spacing: 1px;
            cursor: pointer; position: relative; overflow: hidden;
            transition: transform 0.2s, box-shadow 0.2s;
            margin-top: 10px; font-family: "Microsoft YaHei", sans-serif;
        }
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px -5px var(--primary-glow);
        }
        .btn-login::after {
            content: ''; position: absolute; top: -50%; left: -50%; width: 200%; height: 200%;
            background: linear-gradient(45deg, transparent, rgba(255,255,255,0.2), transparent);
            transform: rotate(45deg) translate(-100%, -100%);
            animation: shimmer 3s infinite;
        }
        @keyframes shimmer { 100% { transform: rotate(45deg) translate(100%, 100%); } }

        /* 消息提示 */
        .msg-box {
            text-align: center; margin-top: 20px; min-height: 20px;
            font-size: 13px; font-weight: 500;
        }

        /* 背景动画粒子 (纯CSS模拟) */
        .bg-orb {
            position: absolute; border-radius: 50%; filter: blur(80px); opacity: 0.4;
            animation: float 10s infinite ease-in-out;
        }
        .orb-1 { top: -10%; left: -10%; width: 50vw; height: 50vw; background: purple; animation-delay: 0s; }
        .orb-2 { bottom: -10%; right: -10%; width: 40vw; height: 40vw; background: blue; animation-delay: -5s; }
        @keyframes float { 0%, 100% { transform: translate(0,0); } 50% { transform: translate(30px, 50px); } }

        /* 主题切换按钮 */
        .theme-toggle {
            position: absolute; top: 20px; right: 20px;
            background: rgba(255,255,255,0.1); border: none; color: var(--text-main);
            width: 40px; height: 40px; border-radius: 50%; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            transition: all 0.3s;
        }
        .theme-toggle:hover { background: rgba(255,255,255,0.2); transform: rotate(15deg); }
    </style>
</head>
<body>
    <div class="bg-orb orb-1"></div>
    <div class="bg-orb orb-2"></div>

    <button type="button" class="theme-toggle" onclick="toggleTheme()">
        <i class="fas fa-moon" id="themeIcon"></i>
    </button>

    <form id="form1" runat="server">
        <div class="login-card">
            <div class="header">
                <i class="fas fa-atom logo-icon"></i>
                <h1 class="title">智慧教务中枢</h1>
                <p class="subtitle">Intelligent Educational Administration System</p>
            </div>

            <div class="role-switcher">
                <div class="glider" id="glider"></div>
                
                <asp:RadioButton ID="rbStudent" runat="server" GroupName="Role" Checked="true" CssClass="role-radio" ClientIDMode="Static" />
                <label for="rbStudent" class="role-item active" onclick="switchRole(0)">
                    <i class="fas fa-user-graduate"></i> 学生
                </label>

                <asp:RadioButton ID="rbTeacher" runat="server" GroupName="Role" CssClass="role-radio" ClientIDMode="Static" />
                <label for="rbTeacher" class="role-item" onclick="switchRole(1)">
                    <i class="fas fa-chalkboard-teacher"></i> 教师
                </label>

                <asp:RadioButton ID="rbAdmin" runat="server" GroupName="Role" CssClass="role-radio" ClientIDMode="Static" />
                <label for="rbAdmin" class="role-item" onclick="switchRole(2)">
                    <i class="fas fa-user-shield"></i> 管理员
                </label>
            </div>

            <div class="input-group">
                <i class="fas fa-id-card input-icon"></i>
                <asp:TextBox ID="txtUser" runat="server" CssClass="form-control" placeholder="请输入学号 / 工号"></asp:TextBox>
            </div>
            
            <div class="input-group">
                <i class="fas fa-lock input-icon"></i>
                <asp:TextBox ID="txtPwd" runat="server" CssClass="form-control" TextMode="Password" placeholder="请输入密码"></asp:TextBox>
            </div>

            <asp:Button ID="btnLogin" runat="server" Text="立即登录" OnClick="btnLogin_Click" CssClass="btn-login" />

            <div class="msg-box">
                <asp:Label ID="lblMsg" runat="server" ForeColor="#ef4444"></asp:Label>
            </div>
        </div>
    </form>

    <script>
        // ==========================================
        // 1. 主题切换逻辑
        // ==========================================
        const html = document.documentElement;
        const themeIcon = document.getElementById('themeIcon');
        const savedTheme = localStorage.getItem('theme') || 'dark';

        applyTheme(savedTheme);

        function toggleTheme() {
            const current = html.getAttribute('data-theme');
            const target = current === 'dark' ? 'light' : 'dark';
            applyTheme(target);
            localStorage.setItem('theme', target);
        }

        function applyTheme(theme) {
            html.setAttribute('data-theme', theme);
            themeIcon.className = theme === 'dark' ? 'fas fa-moon' : 'fas fa-sun';
        }

        // ==========================================
        // 2. 身份滑块动画 (兼顾 PostBack 状态恢复)
        // ==========================================
        // 页面加载时恢复滑块位置
        window.onload = function () {
            if (document.getElementById('<%= rbTeacher.ClientID %>').checked) switchRole(1);
            else if (document.getElementById('<%= rbAdmin.ClientID %>').checked) switchRole(2);
            else switchRole(0);
        };

        function switchRole(index) {
            const glider = document.getElementById('glider');
            const items = document.querySelectorAll('.role-item');

            // 移动滑块
            glider.style.transform = `translateX(${index * 100}%)`;

            // 切换激活状态样式
            items.forEach(i => i.classList.remove('active'));
            items[index].classList.add('active');

            // 触发 RadioButton 点击 (确保后端能读到值)
            // 注意：这里用 setTimeout 防止点击 Label 时的递归死循环
            // 实际点击 Label 已经触发了 input，这里主要是视觉同步
        }
    </script>
</body>
</html>