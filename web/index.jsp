<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%!
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#x27;");
    }
%>
<%
    String rawMsg = request.getParameter("msg");
    String rawError = request.getParameter("error");

    String userNotice = null;
    String userError = null;

    if (rawMsg != null) {
        String trimmed = rawMsg.trim();

        if ("logged_out".equalsIgnoreCase(trimmed)
                || "logout".equalsIgnoreCase(trimmed)) {
            userNotice = "You have been logged out successfully.";
        } else if ("registered".equalsIgnoreCase(trimmed)
                || "reg_success".equalsIgnoreCase(trimmed)) {
            userNotice = "Your account has been created successfully. Please sign in.";
        } else if ("booked".equalsIgnoreCase(trimmed)) {
            userNotice = "Your appointment has been booked successfully.";
        }
    }

    if (rawError != null) {
        String trimmed = rawError.trim();

        if ("invalid_credentials".equalsIgnoreCase(trimmed)
                || "auth_failed".equalsIgnoreCase(trimmed)) {
            userError = "Invalid email or password. Please try again.";
        } else if ("email_exists".equalsIgnoreCase(trimmed)) {
            userError = "An account with this email address already exists.";
        } else if ("slot_unavailable".equalsIgnoreCase(trimmed)
                || "conflict".equalsIgnoreCase(trimmed)) {
            userError = "This appointment slot is no longer available. Please choose another time.";
        } else if ("session_expired".equalsIgnoreCase(trimmed)) {
            userError = "Your session has expired. Please sign in again.";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="theme-color" content="#0f766e">

    <title>Online Appointment Booking System</title>

    <link rel="stylesheet" href="css/style.css">

    <style>
        :root {
            --brand: #0f766e;
            --brand-hover: #115e59;
            --brand-soft: #e8f5f3;
            --accent: #3b82f6;

            --page-bg: #f5f7fa;
            --surface: #ffffff;

            --text-main: #1e293b;
            --text-muted: #64748b;

            --border: #e2e8f0;

            --success-bg: #ecfdf5;
            --success-text: #047857;

            --error-bg: #fef2f2;
            --error-text: #b91c1c;

            --radius: 18px;
            --shadow: 0 18px 48px rgba(15, 23, 42, 0.08);
        }

        * {
            box-sizing: border-box;
        }

        html {
            min-height: 100%;
            scroll-behavior: smooth;
        }

        body {
            margin: 0;
            min-height: 100vh;
            background: var(--page-bg);
            color: var(--text-main);
            font-family: Inter, "Segoe UI", Arial, sans-serif;
            -webkit-font-smoothing: antialiased;
        }

        button,
        input,
        select {
            font: inherit;
        }

        button {
            -webkit-tap-highlight-color: transparent;
        }

        a {
            color: inherit;
        }

        /* ================= HEADER ================= */

        .site-header {
            width: 100%;
            background: rgba(255, 255, 255, 0.96);
            border-bottom: 1px solid var(--border);
        }

        .header-inner {
            max-width: 1220px;
            min-height: 78px;
            margin: 0 auto;
            padding: 14px 28px;

            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
        }

        .brand {
            display: inline-flex;
            align-items: center;
            gap: 12px;
            min-width: 0;
            text-decoration: none;
        }

        .brand-mark {
            width: 42px;
            height: 42px;
            flex: 0 0 42px;

            display: grid;
            place-items: center;

            border-radius: 13px;
            color: #ffffff;
            background: var(--brand);

            box-shadow: 0 6px 14px rgba(15, 118, 110, 0.18);
        }

        .brand-mark svg {
            width: 23px;
            height: 23px;
        }

        .brand-name {
            font-size: 1.02rem;
            font-weight: 750;
            line-height: 1.3;
            letter-spacing: -0.025em;
            color: var(--text-main);
        }

        .brand-name span {
            display: block;
            color: var(--brand);
        }

        .secure-label {
            display: inline-flex;
            align-items: center;
            gap: 8px;

            padding: 9px 13px;

            border: 1px solid #cce8e3;
            border-radius: 999px;

            background: #f0fdfa;
            color: var(--brand-hover);

            font-size: 0.82rem;
            font-weight: 650;
            white-space: nowrap;
        }

        .secure-label svg {
            width: 16px;
            height: 16px;
            flex-shrink: 0;
        }

        /* ================= MAIN LAYOUT ================= */

        .page-shell {
            max-width: 1220px;
            min-height: calc(100vh - 145px);

            margin: 0 auto;
            padding: 52px 28px 42px;

            display: grid;
            grid-template-columns:
                minmax(0, 1.08fr)
                minmax(390px, 0.82fr);

            align-items: center;
            gap: clamp(42px, 7vw, 92px);
        }

        /* ================= INTRO SECTION ================= */

        .intro {
            padding: 6px 0;
        }

        .eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 8px;

            margin: 0 0 19px;

            color: var(--brand);
            font-size: 0.79rem;
            font-weight: 750;
            letter-spacing: 0.09em;
            text-transform: uppercase;
        }

        .eyebrow::before {
            content: "";

            width: 24px;
            height: 2px;

            border-radius: 3px;
            background: var(--brand);
        }

        .intro h1 {
            max-width: 620px;

            margin: 0 0 20px;

            color: #172b3a;
            font-size: clamp(2.25rem, 4vw, 3.55rem);
            line-height: 1.1;
            letter-spacing: -0.055em;
            font-weight: 780;
        }

        .intro h1 .highlight {
            color: var(--brand);
        }

        .intro-copy {
            max-width: 560px;

            margin: 0;

            color: var(--text-muted);
            font-size: 1.06rem;
            line-height: 1.8;
        }

        .feature-list {
            display: grid;
            gap: 17px;

            margin: 32px 0 0;
            padding: 0;

            list-style: none;
        }

        .feature-item {
            display: flex;
            align-items: flex-start;
            gap: 13px;

            color: #334155;
            font-size: 0.95rem;
            line-height: 1.55;
        }

        .feature-item strong {
            color: var(--text-main);
            font-weight: 650;
        }

        .feature-icon {
            width: 29px;
            height: 29px;
            flex: 0 0 29px;

            display: grid;
            place-items: center;

            border: 1px solid #b8e2db;
            border-radius: 9px;

            background: var(--brand-soft);
            color: var(--brand);
        }

        .feature-icon svg {
            width: 16px;
            height: 16px;
        }

        .intro-note {
            display: flex;
            align-items: center;
            gap: 10px;

            margin-top: 34px;

            color: #64748b;
            font-size: 0.83rem;
        }

        .intro-note svg {
            width: 17px;
            height: 17px;
            color: var(--brand);
            flex: 0 0 auto;
        }

        /* ================= AUTHENTICATION CARD ================= */

        .auth-card {
            width: 100%;
            max-width: 470px;
            justify-self: end;

            padding: clamp(25px, 3vw, 36px);

            background: var(--surface);

            border: 1px solid #e5eaf0;
            border-radius: 22px;

            box-shadow: var(--shadow);
        }

        .auth-heading {
            margin-bottom: 25px;
        }

        .auth-heading h2 {
            margin: 0 0 7px;

            color: var(--text-main);
            font-size: 1.55rem;
            font-weight: 750;
            letter-spacing: -0.035em;
        }

        .auth-heading p {
            margin: 0;

            color: var(--text-muted);
            font-size: 0.91rem;
            line-height: 1.55;
        }

        /* ================= ALERT MESSAGES ================= */

        .alert {
            display: flex;
            align-items: flex-start;
            gap: 10px;

            padding: 12px 14px;
            margin: 0 0 18px;

            border: 1px solid transparent;
            border-radius: 11px;

            font-size: 0.88rem;
            line-height: 1.5;
        }

        .alert svg {
            width: 18px;
            height: 18px;
            flex: 0 0 18px;
            margin-top: 1px;
        }

        .alert-success {
            color: var(--success-text);
            background: var(--success-bg);
            border-color: #bbf7d0;
        }

        .alert-error {
            color: var(--error-text);
            background: var(--error-bg);
            border-color: #fecaca;
        }

        /* ================= LOGIN / REGISTER TABS ================= */

        .tab-wrap {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 4px;

            padding: 5px;
            margin-bottom: 25px;

            border: 1px solid var(--border);
            border-radius: 12px;

            background: #f8fafc;
        }

        .auth-tab {
            min-height: 43px;
            padding: 10px 12px;

            border: 0;
            border-radius: 9px;

            background: transparent;
            color: var(--text-muted);

            font-size: 0.9rem;
            font-weight: 650;

            cursor: pointer;

            transition:
                background 0.18s ease,
                color 0.18s ease,
                box-shadow 0.18s ease;
        }

        .auth-tab.active {
            background: var(--brand);
            color: #ffffff;
            box-shadow: 0 3px 8px rgba(15, 118, 110, 0.18);
        }

        .auth-tab:focus-visible,
        .btn:focus-visible,
        .pwd-toggle-btn:focus-visible {
            outline: 3px solid rgba(59, 130, 246, 0.35);
            outline-offset: 2px;
        }

        /* ================= FORMS ================= */

        .form-pane {
            display: none;
        }

        .form-pane.active {
            display: flex;
            flex-direction: column;
            gap: 17px;
        }

        .input-group {
            display: flex;
            flex-direction: column;
            gap: 7px;
        }

        .input-group label {
            color: #334155;
            font-size: 0.86rem;
            font-weight: 650;
        }

        .form-input {
            display: block;
            width: 100%;
            min-height: 48px;

            padding: 12px 14px;

            border: 1px solid #d7e0e9;
            border-radius: 10px;

            outline: none;

            background: #ffffff;
            color: var(--text-main);

            font-size: 0.94rem;

            transition:
                border-color 0.18s ease,
                box-shadow 0.18s ease;
        }

        .form-input::placeholder {
            color: #94a3b8;
        }

        .form-input:focus {
            border-color: var(--brand);
            box-shadow: 0 0 0 3px rgba(15, 118, 110, 0.11);
        }

        /* ================= PASSWORD VISIBILITY ================= */

        .password-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .password-wrapper .form-input {
            padding-right: 48px;
        }

        .pwd-toggle-btn {
            position: absolute;
            right: 7px;

            width: 36px;
            height: 36px;

            display: grid;
            place-items: center;

            border: 0;
            border-radius: 8px;

            background: transparent;
            color: #64748b;

            cursor: pointer;
        }

        .pwd-toggle-btn:hover {
            background: #f1f5f9;
            color: var(--brand);
        }

        .pwd-toggle-btn svg {
            width: 19px;
            height: 19px;
        }

        /* ================= BUTTONS ================= */

        .btn {
            width: 100%;
            min-height: 49px;

            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 9px;

            margin-top: 4px;
            padding: 12px 18px;

            border: 1px solid transparent;
            border-radius: 10px;

            font-size: 0.95rem;
            font-weight: 700;

            cursor: pointer;
            text-decoration: none;

            transition:
                background 0.18s ease,
                transform 0.18s ease,
                box-shadow 0.18s ease;
        }

        .btn-primary {
            background: var(--brand);
            color: #ffffff;
        }

        .btn-primary:hover {
            background: var(--brand-hover);
            box-shadow: 0 5px 13px rgba(15, 118, 110, 0.18);
        }

        .btn:active {
            transform: translateY(1px);
        }

        .btn svg {
            width: 18px;
            height: 18px;
        }

        .auth-footnote {
            margin: 19px 0 0;

            color: #94a3b8;
            text-align: center;

            font-size: 0.77rem;
            line-height: 1.5;
        }

        /* ================= FOOTER ================= */

        .site-footer {
            padding: 17px 24px 22px;

            color: #94a3b8;
            text-align: center;

            font-size: 0.78rem;
        }

        /* ================= TABLET ================= */

        @media (max-width: 900px) {
            .page-shell {
                grid-template-columns:
                    minmax(0, 1fr)
                    minmax(340px, 0.9fr);

                gap: 34px;
                padding-top: 40px;
            }

            .intro h1 {
                font-size: clamp(2rem, 4.2vw, 2.8rem);
            }

            .intro-copy {
                font-size: 0.98rem;
            }

            .auth-card {
                padding: 27px;
            }
        }

        /* ================= MOBILE ================= */

        @media (max-width: 760px) {
            .header-inner {
                min-height: 70px;
                padding: 12px 18px;
            }

            .secure-label {
                font-size: 0.75rem;
                padding: 8px 10px;
            }

            .page-shell {
                min-height: auto;
                grid-template-columns: 1fr;

                gap: 30px;
                padding: 35px 18px 28px;
            }

            .intro {
                max-width: 620px;
            }

            .intro h1 {
                max-width: 540px;
                font-size: clamp(2rem, 7vw, 2.8rem);
            }

            .intro-copy {
                font-size: 0.97rem;
            }

            .feature-list {
                margin-top: 23px;
                gap: 13px;
            }

            .intro-note {
                margin-top: 22px;
            }

            .auth-card {
                max-width: 620px;
                justify-self: stretch;
                margin: 0 auto;
            }

            .site-footer {
                padding-bottom: 20px;
            }
        }

        @media (max-width: 460px) {
            .header-inner {
                padding: 11px 14px;
                gap: 10px;
            }

            .brand {
                gap: 9px;
            }

            .brand-mark {
                width: 37px;
                height: 37px;
                flex-basis: 37px;
                border-radius: 11px;
            }

            .brand-mark svg {
                width: 20px;
                height: 20px;
            }

            .brand-name {
                font-size: 0.87rem;
            }

            .secure-label {
                max-width: 116px;
                white-space: normal;
                line-height: 1.25;
                text-align: center;
                gap: 5px;
            }

            .secure-label svg {
                flex: 0 0 15px;
            }

            .page-shell {
                padding: 28px 14px 24px;
                gap: 25px;
            }

            .intro h1 {
                font-size: 2.05rem;
            }

            .intro-copy {
                font-size: 0.92rem;
                line-height: 1.7;
            }

            .feature-item {
                font-size: 0.88rem;
            }

            .auth-card {
                padding: 22px 18px;
                border-radius: 17px;
            }

            .auth-heading h2 {
                font-size: 1.4rem;
            }

            .tab-wrap {
                margin-bottom: 21px;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            *,
            *::before,
            *::after {
                scroll-behavior: auto !important;
                transition-duration: 0.01ms !important;
                animation-duration: 0.01ms !important;
            }
        }
    </style>
</head>

<body>

    <!-- ================= HEADER ================= -->

    <header class="site-header">
        <div class="header-inner">

            <a class="brand"
               href="index.jsp"
               aria-label="Online Appointment Booking System home">

                <span class="brand-mark" aria-hidden="true">
                    <svg viewBox="0 0 24 24"
                         fill="none"
                         stroke="currentColor"
                         stroke-width="1.8"
                         stroke-linecap="round"
                         stroke-linejoin="round">

                        <rect x="3.5" y="5" width="17" height="16" rx="2.5"></rect>
                        <path d="M7.5 3v4M16.5 3v4M3.5 10h17"></path>
                        <path d="m8.5 15 2.2 2.2 4.8-4.8"></path>
                    </svg>
                </span>

                <span class="brand-name">
                    Online Appointment
                    <span>Booking System</span>
                </span>

            </a>

            <span class="secure-label">

                <svg viewBox="0 0 24 24"
                     fill="none"
                     stroke="currentColor"
                     stroke-width="1.8"
                     stroke-linecap="round"
                     stroke-linejoin="round"
                     aria-hidden="true">

                    <rect x="4.5" y="10" width="15" height="11" rx="2"></rect>
                    <path d="M8 10V7a4 4 0 0 1 8 0v3"></path>
                    <path d="m10 15 1.5 1.5L14.5 13"></path>
                </svg>

                Secure Booking Portal

            </span>

        </div>
    </header>


    <!-- ================= MAIN CONTENT ================= -->

    <main class="page-shell">

        <!-- LEFT INTRODUCTION -->

        <section class="intro" aria-labelledby="page-title">

            <p class="eyebrow">
                Simple. Secure. Convenient.
            </p>

            <h1 id="page-title">
                Appointments made
                <span class="highlight">easy.</span>
            </h1>

            <p class="intro-copy">
                Book and manage appointments in one place.
                Connect with service providers across academic,
                medical, and legal services through a straightforward
                scheduling experience.
            </p>

            <ul class="feature-list">

                <li class="feature-item">

                    <span class="feature-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24"
                             fill="none"
                             stroke="currentColor"
                             stroke-width="2"
                             stroke-linecap="round"
                             stroke-linejoin="round">

                            <path d="M12 8v4l2.5 1.5"></path>
                            <circle cx="12" cy="12" r="9"></circle>
                        </svg>
                    </span>

                    <span>
                        <strong>Convenient scheduling</strong>
                        <br>
                        Choose appointment times that fit your schedule.
                    </span>

                </li>

                <li class="feature-item">

                    <span class="feature-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24"
                             fill="none"
                             stroke="currentColor"
                             stroke-width="2"
                             stroke-linecap="round"
                             stroke-linejoin="round">

                            <path d="M4 5h16v15H4z"></path>
                            <path d="M8 3v4M16 3v4M4 10h16"></path>
                            <path d="m8 14 2 2 4-4"></path>
                        </svg>
                    </span>

                    <span>
                        <strong>Clear appointment details</strong>
                        <br>
                        Review your selected date, time, and booking status.
                    </span>

                </li>

                <li class="feature-item">

                    <span class="feature-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24"
                             fill="none"
                             stroke="currentColor"
                             stroke-width="2"
                             stroke-linecap="round"
                             stroke-linejoin="round">

                            <path d="M12 22s8-4 8-11V5l-8-3-8 3v6c0 7 8 11 8 11z"></path>
                            <path d="m9 12 2 2 4-4"></path>
                        </svg>
                    </span>

                    <span>
                        <strong>Role-based access</strong>
                        <br>
                        Dedicated experiences for seekers and service providers.
                    </span>

                </li>

            </ul>

            <div class="intro-note">

                <svg viewBox="0 0 24 24"
                     fill="none"
                     stroke="currentColor"
                     stroke-width="1.8"
                     stroke-linecap="round"
                     stroke-linejoin="round"
                     aria-hidden="true">

                    <circle cx="12" cy="12" r="9"></circle>
                    <path d="M12 11v5M12 7h.01"></path>
                </svg>

                <span>
                    Sign in to manage your appointments securely.
                </span>

            </div>

        </section>


        <!-- RIGHT AUTHENTICATION PANEL -->

        <section class="auth-card" aria-labelledby="auth-title">

            <% if (userNotice != null) { %>

                <div class="alert alert-success" role="status">

                    <svg viewBox="0 0 24 24"
                         fill="none"
                         stroke="currentColor"
                         stroke-width="2"
                         stroke-linecap="round"
                         stroke-linejoin="round"
                         aria-hidden="true">

                        <circle cx="12" cy="12" r="9"></circle>
                        <path d="m8 12 2.5 2.5L16 9"></path>
                    </svg>

                    <span><%= escapeHtml(userNotice) %></span>

                </div>

            <% } %>


            <% if (userError != null) { %>

                <div class="alert alert-error" role="alert">

                    <svg viewBox="0 0 24 24"
                         fill="none"
                         stroke="currentColor"
                         stroke-width="2"
                         stroke-linecap="round"
                         stroke-linejoin="round"
                         aria-hidden="true">

                        <circle cx="12" cy="12" r="9"></circle>
                        <path d="M12 8v5M12 16h.01"></path>
                    </svg>

                    <span><%= escapeHtml(userError) %></span>

                </div>

            <% } %>


            <div class="auth-heading">

                <h2 id="auth-title">
                    Welcome back
                </h2>

                <p id="auth-subtitle">
                    Sign in to continue to your account.
                </p>

            </div>


            <!-- LOGIN / REGISTER TABS -->

            <div class="tab-wrap"
                 role="tablist"
                 aria-label="Account access">

                <button type="button"
                        class="auth-tab active"
                        id="btn-tab-login"
                        role="tab"
                        aria-selected="true"
                        aria-controls="pane-login"
                        onclick="setAuthTab('login')">

                    Sign In

                </button>

                <button type="button"
                        class="auth-tab"
                        id="btn-tab-reg"
                        role="tab"
                        aria-selected="false"
                        aria-controls="pane-reg"
                        onclick="setAuthTab('register')">

                    Create Account

                </button>

            </div>


            <!-- ================= LOGIN FORM ================= -->

            <form action="auth"
                  method="post"
                  id="pane-login"
                  class="form-pane active"
                  role="tabpanel"
                  aria-labelledby="btn-tab-login">

                <input type="hidden" name="action" value="login">


                <div class="input-group">

                    <label for="login-email">
                        Email address
                    </label>

                    <input type="email"
                           id="login-email"
                           name="email"
                           class="form-input"
                           required
                           autocomplete="email"
                           placeholder="name@example.com">

                </div>


                <div class="input-group">

                    <label for="login-pwd">
                        Password
                    </label>

                    <div class="password-wrapper">

                        <input type="password"
                               id="login-pwd"
                               name="password"
                               class="form-input"
                               required
                               autocomplete="current-password"
                               placeholder="Enter your password">

                        <button type="button"
                                class="pwd-toggle-btn"
                                onclick="togglePassword('login-pwd', this)"
                                aria-label="Show password"
                                title="Show password">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="1.8"
                                 stroke-linecap="round"
                                 stroke-linejoin="round"
                                 aria-hidden="true">

                                <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"></path>
                                <circle cx="12" cy="12" r="3"></circle>
                            </svg>

                        </button>

                    </div>

                </div>


                <button type="submit" class="btn btn-primary">

                    Sign In

                    <svg viewBox="0 0 24 24"
                         fill="none"
                         stroke="currentColor"
                         stroke-width="2"
                         stroke-linecap="round"
                         stroke-linejoin="round"
                         aria-hidden="true">

                        <path d="M5 12h14M13 6l6 6-6 6"></path>
                    </svg>

                </button>

            </form>


            <!-- ================= REGISTRATION FORM ================= -->

            <form action="auth"
                  method="post"
                  id="pane-reg"
                  class="form-pane"
                  role="tabpanel"
                  aria-labelledby="btn-tab-reg">

                <input type="hidden" name="action" value="register">


                <div class="input-group">

                    <label for="reg-name">
                        Full name
                    </label>

                    <input type="text"
                           id="reg-name"
                           name="fullName"
                           class="form-input"
                           required
                           autocomplete="name"
                           placeholder="Enter your full name">

                </div>


                <div class="input-group">

                    <label for="reg-email">
                        Email address
                    </label>

                    <input type="email"
                           id="reg-email"
                           name="email"
                           class="form-input"
                           required
                           autocomplete="email"
                           placeholder="name@example.com">

                </div>


                <div class="input-group">

                    <label for="reg-pwd">
                        Create password
                    </label>

                    <div class="password-wrapper">

                        <input type="password"
                               id="reg-pwd"
                               name="password"
                               class="form-input"
                               required
                               autocomplete="new-password"
                               placeholder="Create a password">

                        <button type="button"
                                class="pwd-toggle-btn"
                                onclick="togglePassword('reg-pwd', this)"
                                aria-label="Show password"
                                title="Show password">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="1.8"
                                 stroke-linecap="round"
                                 stroke-linejoin="round"
                                 aria-hidden="true">

                                <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"></path>
                                <circle cx="12" cy="12" r="3"></circle>
                            </svg>

                        </button>

                    </div>

                </div>


                <div class="input-group">

                    <label for="reg-role">
                        Account type
                    </label>

                    <select id="reg-role"
                            name="role"
                            class="form-input"
                            required>

                        <option value="USER">
                            Service Seeker
                        </option>

                        <option value="PROVIDER">
                            Service Provider
                        </option>

                    </select>

                </div>


                <button type="submit" class="btn btn-primary">

                    Create Account

                    <svg viewBox="0 0 24 24"
                         fill="none"
                         stroke="currentColor"
                         stroke-width="2"
                         stroke-linecap="round"
                         stroke-linejoin="round"
                         aria-hidden="true">

                        <path d="M5 12h14M13 6l6 6-6 6"></path>
                    </svg>

                </button>

            </form>


            <p class="auth-footnote">
                Your account access is managed securely through the application.
            </p>

        </section>

    </main>


    <!-- ================= FOOTER ================= -->

    <footer class="site-footer">

        &copy; <%= java.time.Year.now().getValue() %>
        Online Appointment Booking System. All rights reserved.

    </footer>


    <!-- ================= JAVASCRIPT ================= -->

    <script>

        function setAuthTab(mode) {

            var isLogin = mode === 'login';

            var loginPane = document.getElementById('pane-login');
            var registerPane = document.getElementById('pane-reg');

            var loginTab = document.getElementById('btn-tab-login');
            var registerTab = document.getElementById('btn-tab-reg');

            var title = document.getElementById('auth-title');
            var subtitle = document.getElementById('auth-subtitle');


            loginPane.classList.toggle('active', isLogin);
            registerPane.classList.toggle('active', !isLogin);

            loginTab.classList.toggle('active', isLogin);
            registerTab.classList.toggle('active', !isLogin);

            loginTab.setAttribute(
                'aria-selected',
                String(isLogin)
            );

            registerTab.setAttribute(
                'aria-selected',
                String(!isLogin)
            );


            title.textContent = isLogin
                ? 'Welcome back'
                : 'Create your account';

            subtitle.textContent = isLogin
                ? 'Sign in to continue to your account.'
                : 'Register to start managing your appointments.';

        }


        function togglePassword(inputId, button) {

            var input = document.getElementById(inputId);

            if (!input) {
                return;
            }

            var showing = input.type === 'password';

            input.type = showing ? 'text' : 'password';

            if (button) {

                button.setAttribute(
                    'aria-label',
                    showing ? 'Hide password' : 'Show password'
                );

                button.setAttribute(
                    'title',
                    showing ? 'Hide password' : 'Show password'
                );

            }

        }


        /*
         * Open the registration tab when the server reports
         * a registration success or an existing email address.
         */

        (function () {
            var urlParams = new URLSearchParams(window.location.search);
            var msgParam = (urlParams.get("msg") || "").toLowerCase();
            var errParam = (urlParams.get("error") || "").toLowerCase();

            var isRegistered = msgParam === "registered" || msgParam === "reg_success";
            var isEmailExists = errParam === "email_exists";

            if (isRegistered || isEmailExists) {
                setAuthTab('register');
            }
        })();
    </script>
</body>
</html>