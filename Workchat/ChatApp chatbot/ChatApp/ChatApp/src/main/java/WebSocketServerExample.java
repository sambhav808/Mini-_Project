import org.java_websocket.server.WebSocketServer;
import org.java_websocket.WebSocket;
import org.java_websocket.handshake.ClientHandshake;

import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

public class WebSocketServerExample extends WebSocketServer {

    private final Set<WebSocket> clients = Collections.synchronizedSet(new HashSet<>());

    public WebSocketServerExample(int port) {
        super(new InetSocketAddress(port));
    }

    @Override
    public void onOpen(WebSocket conn, ClientHandshake handshake) {
        clients.add(conn);
        System.out.println("New connection: " + conn.getRemoteSocketAddress());
        conn.send("<p style=\"text-align: center;\">Welcome to the ChatApp!</p>");
        for (WebSocket client : clients) {
                client.send("Online Students : "+ (clients.size()));

        }

    }

    @Override
    public void onClose(WebSocket conn, int code, String reason, boolean remote) {
        clients.remove(conn);
        System.out.println("Closed connection: " + conn.getRemoteSocketAddress());
        for (WebSocket client : clients) {
                client.send("Online Students : "+ (clients.size()));

        }
    }

    @Override
    public void onMessage(WebSocket conn, String message) {
        System.out.println("Text message received: " + message);

        // Broadcast text messages
        synchronized (clients) {
            for (WebSocket client : clients) {
                if (client != conn) {

                    client.send(message);
                }
            }
        }
    }

    @Override
    public void onMessage(WebSocket conn, ByteBuffer message) {
        System.out.println("Binary data received from " + conn.getRemoteSocketAddress());

        // Broadcast binary data
        synchronized (clients) {
            for (WebSocket client : clients) {
                if (client != conn) {
                    client.send(message); // Broadcast binary data
                }
            }
        }
    }

    @Override
    public void onError(WebSocket conn, Exception ex) {
        ex.printStackTrace();
    }

    @Override
    public void onStart() {
        System.out.println("Server started successfully!");
    }

    public static void main(String[] args) {
        int port = 8887; // Default WebSocket port
        WebSocketServer server = new WebSocketServerExample(port);
        server.start();
        System.out.println("WebSocket server started on port " + port);
    }
}