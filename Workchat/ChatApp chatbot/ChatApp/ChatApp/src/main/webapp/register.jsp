<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f4f8;
            margin: 0;
            padding: 0;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background-image: url("./back.jpg");
        }

        .container {
            background-color: #fff;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 400px;
            text-align: center;
        }

        h1 {
            margin-bottom: 20px;
            font-size: 24px;
            color: #333;
        }

        label {
            font-size: 16px;
            color: #555;
            margin-bottom: 10px;
            display: block;
        }

        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 10px;
            font-size: 16px;
            margin-bottom: 20px;
            border: 2px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box;
        }

        button {
            background-color: #273484;
            color: white;
            font-size: 16px;
            padding: 12px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            width: 100%;
            transition: background-color 0.3s ease;
        }

        button:hover {
            background-color: #273484b5;
        }

        .footer {
            margin-top: 20px;
            font-size: 14px;
            color: #888;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>Create an Account</h1>

    <!-- Registration Form -->
    <form action="registerServlet" method="post">
        <label for="uniqueName">Unique Name:</label>
        <input type="text" id="uniqueName" name="uniqueName" required
               placeholder="Enter a UniqueName (min 5 characters)"
               minlength="5"
               title="UniqueName must be at least 5 characters long">

        <label for="username">Username:</label>
        <input type="text" id="username" name="username" required
               placeholder="Enter a username (min 5 characters)"
               minlength="5"
               title="Username must be at least 5 characters long">

        <label for="password">Password:</label>
        <input type="password" id="password" name="password" required placeholder="Enter your password">

        <button type="submit">Register</button>
    </form>
    <!-- Display the error message if it exists -->
    <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
    <% if (errorMessage != null) { %>
    <div class="error-message" style="color: red">
        <%= errorMessage %>
    </div>
    <% } %>
    <div class="footer">
        <p>Already have an account? <a href="index.jsp">Login here</a></p>
    </div>

</div>
</body>
</html>
