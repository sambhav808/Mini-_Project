import org.java_websocket.client.WebSocketClient;
import org.java_websocket.handshake.ServerHandshake;

import javax.swing.*;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URI;
import java.nio.ByteBuffer;
import java.nio.file.Files;

public class WebSocketClientExample extends WebSocketClient {

    private JTextArea chatArea;

    public WebSocketClientExample(URI serverURI, JTextArea chatArea) {
        super(serverURI);
        this.chatArea = chatArea;
    }

    @Override
    public void onOpen(ServerHandshake handshakeData) {
        System.out.println("Connected to server");
    }
    //Method Overloading -> Same name Different Argument
    @Override
    public void onMessage(String message) {
        System.out.println("Message from server: " + message);
        chatArea.append("Server: " + message + "\n"); // Display received text message in chat area
    }

    @Override
    public void onMessage(ByteBuffer message) {
        System.out.println("Binary message received!");

        // Save the received binary data as a file (image or any file)
        try (FileOutputStream fos = new FileOutputStream("received_file")) {
            fos.write(message.array());
            System.out.println("File saved as 'received_file'");

            // Display the file in chat (only for images in this example)
            chatArea.append("Received a file. You can download it!\n");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onClose(int code, String reason, boolean remote) {
        System.out.println("Disconnected from server");
    }

    @Override
    public void onError(Exception ex) {
        ex.printStackTrace();
    }

    public static void main(String[] args) throws Exception {
        URI serverUri = new URI("ws://localhost:8887");
        JFrame frame = new JFrame("WebSocket Chat");

        // Setup chat UI
        JTextArea chatArea = new JTextArea(20, 40);
        chatArea.setEditable(false);
        JScrollPane scrollPane = new JScrollPane(chatArea);
        frame.add(scrollPane);

        // Message input field
        JTextField textField = new JTextField(30);
        frame.add(textField, "South");

        JButton sendButton = new JButton("Send");
        frame.add(sendButton, "South");

        // File chooser button
        JButton fileButton = new JButton("Send File");
        frame.add(fileButton, "South");

        frame.setLayout(new BoxLayout(frame.getContentPane(), BoxLayout.Y_AXIS));
        frame.setSize(500, 500);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setVisible(true);

        WebSocketClientExample client = new WebSocketClientExample(serverUri, chatArea);
        client.connect();

        // Wait for connection
        while (!client.isOpen()) {
            Thread.sleep(100);
        }

        sendButton.addActionListener(e -> {
            String message = textField.getText();
            if (!message.isEmpty()) {
                client.send(message); // Send text message
                chatArea.append("You: " + message + "\n"); // Display message in chat
                textField.setText("");
            }
        });

        fileButton.addActionListener(e -> {
            JFileChooser fileChooser = new JFileChooser();
            fileChooser.setDialogTitle("Select a File to Send");
            int result = fileChooser.showOpenDialog(frame);
            if (result == JFileChooser.APPROVE_OPTION) {
                File selectedFile = fileChooser.getSelectedFile();
                System.out.println("Selected file: " + selectedFile.getAbsolutePath());

                try {
                    byte[] fileBytes = Files.readAllBytes(selectedFile.toPath());
                    client.send(ByteBuffer.wrap(fileBytes)); // Send binary data (file)
                    chatArea.append("You sent a file: " + selectedFile.getName() + "\n");
                } catch (IOException ex) {
                    System.err.println("Error reading file: " + ex.getMessage());
                }
            }
        });
    }
}