package servlet;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.hibernate.Session;
import org.hibernate.query.Query;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import servlet.User;

public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uniqueName = request.getParameter("uniqueName");
        //String username = request.getParameter("username");
        String password = request.getParameter("password");

        System.out.println(uniqueName);
        // Set up Hibernate session
        SessionFactory factory = new Configuration().configure("hibernate.cfg.xml")
                .addAnnotatedClass(User.class)
                .buildSessionFactory();
        Session session = factory.getCurrentSession();
        session.beginTransaction();

        try {
            // Create HQL query to check user credentials
            String hql = "FROM User WHERE uniqueName = :uniqueName AND password = :password";
            System.out.println(uniqueName +"  "+password);
            Query<User> query = session.createQuery(hql, User.class);
            query.setParameter("uniqueName", uniqueName);
            query.setParameter("password", password);

            User user = query.uniqueResult();

            if (user != null) {
                // Successful login
                HttpSession httpSession = request.getSession();
                httpSession.setAttribute("username", user.getUsername()); // Store user in session
                request.setAttribute("username", user.getUsername());
                httpSession.setAttribute("uniqueName", user.getUniqueName()); // Store user in session
                request.setAttribute("uniqueName", user.getUniqueName());
                request.getRequestDispatcher("/chatroom.jsp").forward(request, response);
                session.getTransaction().commit();
            } else {
                // Login failed
                request.setAttribute("errorMessage", "Invalid username or password");
                RequestDispatcher dispatcher = request.getRequestDispatcher("index.jsp");
                dispatcher.forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            factory.close();
        }
    }
}
