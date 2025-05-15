package servlet;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;
import com.google.gson.Gson;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

public class AssignmentServlet extends HttpServlet {

    private SessionFactory factory = new Configuration()
            .configure("hibernate.cfg.xml")
            .addAnnotatedClass(Assignment.class)
            .buildSessionFactory();

    // Helper method to send JSON responses
    private void sendJsonResponse(HttpServletResponse response, Object obj, int statusCode) throws IOException {
        response.setContentType("application/json");
        response.setStatus(statusCode);
        PrintWriter out = response.getWriter();
        out.println(new Gson().toJson(obj));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String userId = (String) request.getParameter("userId");
        System.out.println("action: " + action + ", userId: " + userId);
        if (userId == null || userId.isEmpty()) {
            sendJsonResponse(response, "{\"error\": \"User not logged in\"}", HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        if (action == null || action.isEmpty()) {
            fetchAssignmentsForUser(response, userId);
        } else if ("description".equalsIgnoreCase(action)) {
            int assignmentId = Integer.parseInt(request.getParameter("id"));
            fetchAssignmentDescription(response, assignmentId);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String userId = (String) request.getParameter("userId");

        if (userId == null || userId.isEmpty()) {
            sendJsonResponse(response, "{\"error\": \"User not logged in\"}", HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        if ("add".equalsIgnoreCase(action)) {
            String targetUserId = request.getParameter("targetUserId");
            String description = request.getParameter("description");
            addAssignmentForUser(response, targetUserId, description);
        } else if ("submit".equalsIgnoreCase(action)) {
            int assignmentId = Integer.parseInt(request.getParameter("id"));
            submitAssignment(response, assignmentId);
        } else {
            String description = request.getParameter("description");
            addAssignmentForUser(response, userId, description);
        }
    }

    private void fetchAssignmentsForUser(HttpServletResponse response, String userId) throws IOException {
        List<Assignment> assignments;
        System.out.println("userId: " + userId);
        try (Session session = factory.openSession()) {
            assignments = session.createQuery("FROM Assignment WHERE userId = :userId", Assignment.class)
                    .setParameter("userId", userId)
                    .list();
        }

        if (assignments.isEmpty()) {
            sendJsonResponse(response, "{\"message\": \"No assignments found\"}", HttpServletResponse.SC_OK);
        } else {
            sendJsonResponse(response, assignments, HttpServletResponse.SC_OK);
        }
    }

    private void fetchAssignmentDescription(HttpServletResponse response, int assignmentId) throws IOException {
        Assignment assignment;

        try (Session session = factory.openSession()) {
            assignment = session.get(Assignment.class, assignmentId);
        }

        if (assignment != null) {
            sendJsonResponse(response, assignment.getDescription(), HttpServletResponse.SC_OK);
        } else {
            sendJsonResponse(response, "{\"error\": \"Assignment not found\"}", HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void addAssignmentForUser(HttpServletResponse response, String userId, String description) throws IOException {
        if (description == null || description.isEmpty()) {
            sendJsonResponse(response, "{\"error\": \"Assignment description is required\"}", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Assignment assignment = new Assignment(userId, description);

        try (Session session = factory.openSession()) {
            Transaction tx = session.beginTransaction();
            session.save(assignment);  // Save the assignment to the database
            tx.commit();
        }

        sendJsonResponse(response, "{\"message\": \"Assignment added successfully\"}", HttpServletResponse.SC_CREATED);
    }

    private void submitAssignment(HttpServletResponse response, int assignmentId) throws IOException {
        try (Session session = factory.openSession()) {
            Transaction tx = session.beginTransaction();
            Assignment assignment = session.get(Assignment.class, assignmentId);
            if (assignment != null) {
                assignment.setStatus("Submitted");  // Assuming Assignment has a "status" field
                session.update(assignment);
                tx.commit();
                sendJsonResponse(response, "{\"message\": \"Assignment submitted successfully\"}", HttpServletResponse.SC_OK);
            } else {
                sendJsonResponse(response, "{\"error\": \"Assignment not found\"}", HttpServletResponse.SC_NOT_FOUND);
            }
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int assignmentId = Integer.parseInt(request.getParameter("id"));

        try (Session session = factory.openSession()) {
            Transaction tx = session.beginTransaction();
            Assignment assignment = session.get(Assignment.class, assignmentId);
            if (assignment != null) {
                session.delete(assignment);
                tx.commit();
                sendJsonResponse(response, "{\"message\": \"Assignment deleted successfully\"}", HttpServletResponse.SC_NO_CONTENT);
            } else {
                sendJsonResponse(response, "{\"error\": \"Assignment not found\"}", HttpServletResponse.SC_NOT_FOUND);
            }
        }
    }

    @Override
    public void destroy() {
        factory.close();  // Close Hibernate session factory
    }
}
