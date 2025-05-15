package servlet;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.hibernate.Session;
import org.hibernate.query.Query;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import servlet.User;

public class RegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uniqueName = request.getParameter("uniqueName");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Set up Hibernate session
        SessionFactory factory = new Configuration().configure("hibernate.cfg.xml")
                .addAnnotatedClass(User.class)
                .buildSessionFactory();
        Session session = factory.getCurrentSession();
        session.beginTransaction();

        System.out.println("-----------------"+username);
        try {
            // Check if the username already exists
            String hql = "FROM User WHERE uniqueName = :uniqueName";
            Query<User> query = session.createQuery(hql, User.class);
            query.setParameter("uniqueName", uniqueName);
            User existingUser = query.uniqueResult();
            if (existingUser != null) {
                // Username already exists, show an error message
                request.setAttribute("errorMessage", "UniqueName already taken.");
                RequestDispatcher dispatcher = request.getRequestDispatcher("register.jsp");
                dispatcher.forward(request, response);
            } else {
                // Create new User object and save to the database
                User newUser = new User();
                newUser.setUniqueName(uniqueName);
                newUser.setUsername(username);
                newUser.setPassword(password);
                System.out.println(newUser.getUniqueName() +"  "+uniqueName);
                // Begin transaction
                session.save(newUser);
                session.getTransaction().commit();

                // Redirect to login page after successful registration
                response.sendRedirect("index.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {

            factory.close();
        }
    }
}
