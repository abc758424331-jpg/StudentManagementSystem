<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AddStudent.aspx.cs" Inherits="AddStudent" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" data-theme="dark">
<head runat="server">
    <title>Enroll Student | 智慧教务中枢</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Rajdhani:wght@500;700&display=swap" rel="stylesheet">
    <link href="Style.css" rel="stylesheet" />
    
    <style>
        /* === 管理员主题 (绿色系) === */
        .page-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 30px; padding-bottom: 20px; border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        .header-title h2 { margin: 0; font-family: 'Rajdhani', sans-serif; font-weight: 700; color: #fff; }
        
        .form-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px;
        }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; color: #94a3b8; margin-bottom: 8px; font-size: 14px; }
        .form-control {
            width: 100%; padding: 12px; background: rgba(15, 23, 42, 0.5);
            border: 1px solid rgba(255,255,255,0.1); border-radius: 6px;
            color: #fff; font-family: 'Inter', sans-serif; transition: all 0.3s;
        }
        .form-control:focus { border-color: #10b981; outline: none; box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.2); }
        
        .btn-submit {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white; border: none; padding: 12px 30px; border-radius: 6px;
            font-weight: 600; cursor: pointer; transition: transform 0.2s;
            display: inline-flex; align-items: center; gap: 8px;
        }
        .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3); }

        .btn-back {
            background: rgba(255,255,255,0.05); color: #94a3b8; padding: 10px 20px; 
            border-radius: 6px; text-decoration: none; font-size: 14px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div style="background: rgba(15, 23, 42, 0.9); padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255,255,255,0.05);">
            <div style="font-family: 'Rajdhani'; font-weight: 700; font-size: 20px; color: #10b981;">
                <i class="fas fa-shield-alt"></i> ADMIN-CORE
            </div>
            <div style="display: flex; gap: 20px; align-items: center;">
                <span style="color: #94a3b8;"><i class="fas fa-user-circle"></i> <asp:Label ID="lblUser" runat="server"></asp:Label></span>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" style="color: #ef4444; text-decoration:none;">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </asp:LinkButton>
            </div>
        </div>

        <div class="container">
            <div class="page-header">
                <div class="header-title">
                    <h2>Enroll New Student</h2>
                    <p style="color:#64748b; margin:5px 0 0 0;">Create student profile and assign initial class.</p>
                </div>
                <a href="Default.aspx" class="btn-back"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
            </div>

            <div class="form-grid">
                <div>
                    <div class="form-group">
                        <label>Student ID (Unique)</label>
                        <asp:TextBox ID="txtStuNo" runat="server" CssClass="form-control" placeholder="e.g. 2023001"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Full Name</label>
                        <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="Student Name"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Gender</label>
                        <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-control">
                            <asp:ListItem Value="Male">Male</asp:ListItem>
                            <asp:ListItem Value="Female">Female</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <div>
                    <div class="form-group">
                        <label>Class Assignment</label>
                        <asp:DropDownList ID="ddlClass" runat="server" CssClass="form-control"></asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label>Phone Number</label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="Contact Number"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Default Password</label>
                        <input type="text" class="form-control" value="123456" disabled style="background:rgba(0,0,0,0.2); cursor:not-allowed;" />
                    </div>
                </div>
            </div>

            <div style="margin-top: 30px; border-top: 1px solid rgba(255,255,255,0.1); padding-top: 20px; display:flex; align-items:center; gap:20px;">
                <asp:Button ID="btnSave" runat="server" Text="Save Student Profile" OnClick="btnSave_Click" CssClass="btn-submit" />
                <asp:Label ID="lblMsg" runat="server" style="font-weight:600;"></asp:Label>
            </div>
        </div>
    </form>
</body>
</html>