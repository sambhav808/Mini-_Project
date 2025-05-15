<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Study Room</title>
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
            background-color: #273484;
            color: white;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        button:hover {
            background-color: #273484b5;
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
    <h2 style="text-align:center; color:#333;margin-bottom: 0;">Study Room </h2><p id="Online" style="text-align: right; margin-top: 0;">Online : 0<p>
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
    const receivedFiles = [];

    // Initialize WebSocket connection
    function connectWebSocket(username) {
        socket = new WebSocket(serverUrl);

        socket.onopen = function () {
            console.log("Connected to WebSocket server.");
            const chatBox = document.getElementById("chatBox");

            chatBox.innerHTML +="<p style=\"text-align: center;\">You joined the chat.</p>";
            socket.send("<p style=\"text-align: center;\">"+username + " has joined the chat.</p>");
        };

        socket.onmessage = function (event) {
            const chatBox = document.getElementById("chatBox");

            if (typeof event.data === "string") {
                if(event.data.includes("Online")){
                    const online = document.getElementById("Online");
                    online.innerHTML =  event.data ;

                }else{
                    chatBox.innerHTML += "<p>" + event.data + "</p>";
                }
            } else if (event.data instanceof Blob) {
                console.log("Received Blob:", event.data);

                const fileUrl = URL.createObjectURL(event.data);
                console.log("Generated File URL:", fileUrl); // Debug log
                //const fileName = "file_"+Date.now();

                const filenameElements = document.querySelectorAll('p[id="filename"]');
                const lastFilenameElement = filenameElements[filenameElements.length - 1];
                const fileName = lastFilenameElement ? lastFilenameElement.innerText : 'downloaded_file';

                // Save the file URL and name for later use
                receivedFiles.push({ fileUrl, fileName });

                if (!fileUrl) {
                    chatBox.innerHTML += `<p>Error: File URL is empty.</p>`;
                    return;
                }
                receivedFileBlob = event.data;
                console.log(event.data);
                //const fileUrl = URL.createObjectURL(event.data);
                console.log(fileUrl);
                console.log(fileName);
                chatBox.innerHTML += "<p>Received an file or image: <button class=\"download-button\" onclick=\"downloadFile('  ', '"+fileName+"')\">Download File</button></p>";

                console.log(receivedFiles);

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
        chatBox.innerHTML += "<div><strong><p style=\"display: inline;\">Filename : </p><p id='filename' style=\"display: inline;\">" + file.name + "</p></strong></div>";

        if (file) {
            const reader = new FileReader();
            reader.onload = function (event) {
                const message ="<strong><p style=\"display: inline;\">Filename : </p><p id='filename' style=\"display: inline;\">" + file.name + "</p></strong></div>";
                socket.send(message);
                const fileData = new Blob([event.target.result], { type: file.type });
                socket.send(fileData);

            };
            reader.readAsArrayBuffer(file);
        }
    }

    // Download the file
    function downloadFile(fileUrl, fileName) {
        // Check the last filename element for a valid name
        console.log(fileName);
        console.log(receivedFiles)
        const file = receivedFiles.find(f => f.fileName === fileName);

        console.log(file.fileUrl);

        //const filenameElements = document.querySelectorAll('p[id="filename"]');
        //const lastFilenameElement = filenameElements[filenameElements.length - 1];
        //fileName = lastFilenameElement ? lastFilenameElement.innerText : 'downloaded_file';

        const a = document.createElement('a');
        a.href = file.fileUrl;
        a.download = fileName; // Use the retrieved file name
        document.body.appendChild(a); // Append to body to ensure proper behavior
        a.click();
        document.body.removeChild(a); // Cleanup
        console.log("File URL:", fileUrl);
        console.log("File Name:", fileName);

    }


    // Initialize connection on page load
    window.onload = function () {
        const username = "<%= request.getAttribute("username") %>";
        connectWebSocket(username);
    };
</script>
<div id="chatbot-container" style="display: none; flex-direction: column; width: 500px; height: 400px; border: 1px solid #ccc; position: fixed; bottom: 50px; right: 10px; background-color: white;">
    <div id="chatbot-header" style="background-color: #273484; color: white; padding: 10px;">Chatbot</div>
    <div id="chatbot-messages" style="flex: 1; overflow-y: auto; padding: 10px;"></div>
    <div id="chatbot-input-container" style="display: flex; padding: 10px;">
        <input type="text" id="chatbot-input" placeholder="Ask a question..." style="flex: 1; padding: 5px;" oninput="showSuggestions()">
        <button id="chatbot-send-button" onclick="sendChatbotMessage()" style="margin-left: 5px; padding: 5px 10px;">Send</button>
    </div>
    <div id="suggestions-container" style="position: absolute; bottom: 60px; right: 10px; width: 280px; background-color: #fff; border: 1px solid #ccc; display: none; z-index: 10;">
        <ul id="suggestions-list" style="list-style: none; padding: 0; margin: 0;"></ul>
    </div>
</div>
<button onclick="toggleChatbot()" style="position: fixed; bottom: 10px; right: 10px;">Chatbot</button>

<script>
    const functions = [
        "Get Assignments",
        "Submit Assignment {number}",
        "Add Assignment {user uniquename} {assignment description}",
        "Get Assignment Description {number}"
    ];
    const botResponses = [
        "Hi! How can I assist you?",
        "Hello! What can I do for you today?",
        "Hey there! How can I help?",
        "Hello! Let me know how I can assist.",
        "Hi! Feel free to ask me anything.",
        "How can I assist you today?"
    ];
    function getRandomResponse() {
        const randomIndex = Math.floor(Math.random() * botResponses.length);
        return botResponses[randomIndex];
    }
    function showSuggestions() {
        const input = document.getElementById("chatbot-input").value.trim();
        const suggestionsContainer = document.getElementById("suggestions-container");
        const suggestionsList = document.getElementById("suggestions-list");

        // Clear previous suggestions
        suggestionsList.innerHTML = '';

        // If there's any input, show suggestions
        if (input.length > 0) {
            const filteredSuggestions = functions.filter(func => func.toLowerCase().includes(input.toLowerCase()));

            // If there are matching suggestions, display them
            if (filteredSuggestions.length > 0) {
                suggestionsContainer.style.display = 'block';
                filteredSuggestions.forEach(suggestion => {
                    const li = document.createElement("li");
                    li.textContent = suggestion;
                    li.style.padding = '5px';
                    li.style.cursor = 'pointer';
                    li.onclick = () => handleSuggestionClick(suggestion);
                    suggestionsList.appendChild(li);
                });
            } else {
                suggestionsContainer.style.display = 'none'; // Hide if no suggestions
            }
        } else {
            suggestionsContainer.style.display = 'none'; // Hide if input is empty
        }
    }

    function handleSuggestionClick(suggestion) {
        const chatbotInput = document.getElementById("chatbot-input");
        chatbotInput.value = suggestion;
        document.getElementById("suggestions-container").style.display = 'none';
        //sendChatbotMessage();  // Automatically trigger message send after suggestion is selected
    }

    function toggleChatbot() {
        const chatbot = document.getElementById("chatbot-container");
        const randomResponse = getRandomResponse();
        const chatbotMessages = document.getElementById("chatbot-messages");
        chatbotMessages.innerHTML = "<p><strong>Bot:</strong> "+randomResponse+"</p>";
        chatbot.style.display = chatbot.style.display === "none" ? "flex" : "none";
    }

    function sendChatbotMessage() {
        const chatbotInput = document.getElementById("chatbot-input");
        const message = chatbotInput.value.trim();
        const chatbotMessages = document.getElementById("chatbot-messages");

        if (message) {
            chatbotMessages.innerHTML += "<p><strong>You:</strong> "+message+"</p>";

            // Determine action based on the message
            if (message.toLowerCase().startsWith("get assignments")) {
                const userId = "<%= session.getAttribute("uniqueName") %>";
                fetchAssignments(chatbotMessages, userId);
            } else if (message.toLowerCase().startsWith("submit assignment")) {
                const id = extractAssignmentId(message);
                console.log(id)
                if (id) {
                    submitAssignment(chatbotMessages, id);
                } else {
                    chatbotMessages.innerHTML += `<p><strong>Bot:</strong> Please specify the assignment ID.</p>`;
                }
            } else if (message.toLowerCase().startsWith("add assignment")) {
                console.log(message)
                const [targetUserId, description] = extractAssignmentDetails(message.toLowerCase());
                console.log(targetUserId,description)
                if (targetUserId && description) {
                    addAssignment(chatbotMessages, targetUserId, description);
                } else {
                    chatbotMessages.innerHTML += `<p><strong>Bot:</strong> Please specify the target user and description.</p>`;
                }
            } else if (message.toLowerCase().startsWith("get assignment description")) {
                const id = extractAssignmentId(message);
                console.log(id)
                if (id) {
                    fetchAssignmentDescription(chatbotMessages, id);
                } else {
                    chatbotMessages.innerHTML += `<p><strong>Bot:</strong> Please specify the assignment ID.</p>`;
                }
            } else {
                chatbotMessages.innerHTML += `<p><strong>Bot:</strong> I'm still learning. How can I assist you? There are few things I can do mentioned </p>`;
                let assignmentsList = '<ul>';
                functions.forEach(assignment => {
                    assignmentsList += "<li>"+assignment +"</li>";
                });
                assignmentsList += '</ul>';
                chatbotMessages.innerHTML += assignmentsList;
            }

            chatbotInput.value = "";
            chatbotMessages.scrollTop = chatbotMessages.scrollHeight;
        }
    }

    function fetchAssignments(chatbotMessages, userId) {
        if (!userId) {
            chatbotMessages.innerHTML += "<p><strong>Bot:</strong> Please log in first.</p>";
            return;
        }

        // Modify the URL for fetching assignments based on user ID.
        let url = "/ChatApp/assignments?userId=" + userId;

        fetch(url, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' },
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Error fetching assignments: ' + response.statusText);
                }
                return response.json();
            })
            .then(data => {
                // Format the assignment data for display
                if (data && Array.isArray(data) && data.length > 0) {
                    let assignmentsList = '<ul>';
                    data.forEach(assignment => {
                        assignmentsList += "<li>"+assignment.id+" (Status:" +(assignment.status || 'Not submitted')+")</li>";
                    });
                    assignmentsList += '</ul>';
                    chatbotMessages.innerHTML += "<p><strong>Bot:</strong> Your assignments:</p>" + assignmentsList;
                } else {
                    chatbotMessages.innerHTML += "<p><strong>Bot:</strong> You have no assignments.</p>";
                }
                chatbotMessages.scrollTop = chatbotMessages.scrollHeight;
            })
            .catch(error => {
                console.log(error);
                chatbotMessages.innerHTML += "<p><strong>Bot:</strong> Error fetching assignments: " + error.message + "</p>";
                chatbotMessages.scrollTop = chatbotMessages.scrollHeight;
            });
    }

    function fetchAssignmentDescription(chatbotMessages, id) {
        const userId = "<%= session.getAttribute("uniqueName") %>";

        fetch("/ChatApp/assignments?action=description&id="+id+"&userId="+userId, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        })
            .then(response => response.json())
            .then(data => {
                chatbotMessages.innerHTML += "<p><strong>Bot:</strong> Assignment Description: "+data+"</p>";
                chatbotMessages.scrollTop = chatbotMessages.scrollHeight;
            })
            .catch(error => {
                chatbotMessages.innerHTML += "<p><strong>Bot:</strong> Error fetching description: "+error+"</p>";
            });
    }

    function addAssignment(chatbotMessages, targetUserId, description) {
        const userId = "<%= session.getAttribute("uniqueName") %>";

        let url = "/ChatApp/assignments?action=add&userId=" + userId;

        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: "targetUserId="+targetUserId+"&description="+description
        })
            .then(response => {
                if (response.ok) {
                    chatbotMessages.innerHTML += `<p><strong>Bot:</strong> Assignment added successfully.</p>`;
                } else {
                    chatbotMessages.innerHTML += `<p><strong>Bot:</strong> Failed to add assignment.</p>`;
                }
                chatbotMessages.scrollTop = chatbotMessages.scrollHeight;
            })
            .catch(error => {
                chatbotMessages.innerHTML += "<p><strong>Bot:</strong> Error adding assignment: "+error+"</p>";
            });
    }

    function submitAssignment(chatbotMessages, id) {
        const userId = "<%= session.getAttribute("uniqueName") %>";

        fetch("/ChatApp/assignments?action=submit&id="+id+"&userId="+userId, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        })
            .then(response => {
                if (response.ok) {
                    chatbotMessages.innerHTML += `<p><strong>Bot:</strong> Assignment submitted successfully.</p>`;
                } else {
                    chatbotMessages.innerHTML += `<p><strong>Bot:</strong> Failed to submit assignment.</p>`;
                }
                chatbotMessages.scrollTop = chatbotMessages.scrollHeight;
            })
            .catch(error => {
                chatbotMessages.innerHTML += "<p><strong>Bot:</strong> Error submitting assignment: "+error+"</p>";
            });
    }

    function extractAssignmentId(message) {
        console.log(message)
        const match = message.match(/\d+/);

        return match ? parseInt(match[0], 10) : null;
    }

    function extractAssignmentDetails(message) {
        const parts = message.split("add assignment")[1].trim().split(" ");
        if (parts.length >= 2) {
            const targetUserId = parts[0];
            const description = parts.slice(1).join(" ");
            return [targetUserId, description];
        }
        return [null, null];
    }
</script>
</body>

</html>
