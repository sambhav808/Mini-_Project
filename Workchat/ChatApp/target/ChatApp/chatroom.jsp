<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebSocket Chat Room</title>
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
        }

        .chat-container {
            background-color: #fff;
            border-radius: 10px;
            padding: 20px;
            width: 90%;
            max-width: 600px;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
            display: flex;
            flex-direction: column;
            height: 80%;
            max-height: 600px;
        }

        #chatBox {
            flex-grow: 1;
            border: 2px solid #ddd;
            border-radius: 5px;
            background-color: #f9f9f9;
            padding: 10px;
            overflow-y: auto;
            margin-bottom: 20px;
            font-family: sans-serif;
        }

        .input-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }

        input[type="text"] {
            width: 75%;
            padding: 10px;
            font-size: 16px;
            border: 2px solid #ddd;
            border-radius: 5px;
        }

        button {
            padding: 10px 20px;
            font-size: 16px;
            border: none;
            background-color: #4CAF50;
            color: white;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        button:hover {
            background-color: #45a049;
        }

        #fileInput {
            margin-top: 10px;
        }

        img {
            max-width: 100%;
            max-height: 200px;
            margin-top: 10px;
        }

        .download-button {
            width: 30%;
            height: 10%;
            padding: 3px 10px;
        }
    </style>
</head>

<body>
<div class="chat-container">
    <h2 style="text-align:center; color:#333;">WebSocket Chat Room</h2>
    <div id="chatBox">Chat messages will appear here...</div>
    <div class="input-container">
        <input type="text" id="messageInput" placeholder="Type a message...">
        <button onclick="sendMessage()">Send</button>
    </div>
    <input type="file" id="fileInput">
    <button onclick="sendFile()">Send File</button>

</div>


<script>
    const serverUrl = "ws://localhost:8887";
    let socket;
    let receivedFileBlob;

    // Initialize WebSocket connection
    function connectWebSocket(username) {
        socket = new WebSocket(serverUrl);

        socket.onopen = function () {
            console.log("Connected to WebSocket server.");
            socket.send(username + " has joined the chat.");
        };

        socket.onmessage = function (event) {
            const chatBox = document.getElementById("chatBox");

            if (typeof event.data === "string") {
                chatBox.innerHTML += "<p>" + event.data + "</p>";
            } else if (event.data instanceof Blob) {
                receivedFileBlob = event.data;
                console.log(event.data);
                const fileUrl = URL.createObjectURL(event.data);
                chatBox.innerHTML += `<p>Received an file or image: <button class="download-button" onclick="downloadFile('${fileUrl}', 'downloaded_file')">Download File</button></p>`;

                const img = new Image();
                img.onload = function () {
                    chatBox.innerHTML += "<img src='" + fileUrl + "' alt='Received Image' />";
                };
                img.src = fileUrl;


            }
            chatBox.scrollTop = chatBox.scrollHeight;
        };

        socket.onerror = function (error) {
            console.error("WebSocket error:", error);
        };

        socket.onclose = function () {
            console.log("Disconnected from WebSocket server.");
        };
    }

    // Send a text message
    function sendMessage() {
        const input = document.getElementById("messageInput");
        const username = "<%= request.getAttribute("username") %>";
        const message = input.value.trim();
        chatBox.innerHTML +="<p style=\"text-align: right;\">"+ message + ":<strong> " +username+"</strong>" +"</p>" ;

        if (message) {
            socket.send("<strong>"+username + "</strong>: " + message);
            input.value = "";
        }
    }

    // Send a file
    function sendFile() {
        const fileInput = document.getElementById("fileInput");
        const file = fileInput.files[0];
        chatBox.innerHTML += "<strong><p style=\"display: inline;\">Filename : </p><p id='filename' style=\"display: inline;\">" + file.name + "</p></strong>";

        if (file) {
            const reader = new FileReader();
            reader.onload = function (event) {
                const message ="<strong><p style=\"display: inline;\">Filename : </p><p id='filename' style=\"display: inline;\">" + file.name + "</p></strong>";
                socket.send(message);
                const fileData = new Blob([event.target.result], { type: file.type });
                socket.send(fileData);

            };
            reader.readAsArrayBuffer(file);
        }
    }

    // Download the file
    function downloadFile(fileUrl, fileName) {
        const filenameElements = document.querySelectorAll('p[id="filename"]');
        const lastFilenameElement = filenameElements[filenameElements.length - 1]; // Get the last one
         fileName = lastFilenameElement ? lastFilenameElement.innerText : 'downloaded_file';  // Use the filename or default

        const a = document.createElement("a");
        a.href = fileUrl;
        a.download = fileName;
        a.click();
    }

    // Initialize connection on page load
    window.onload = function () {
        const username = "<%= request.getAttribute("username") %>";
        connectWebSocket(username);
    };
</script>
</body>

</html>
